#!/usr/bin/env bash
# LAB ONLY — TIO Sinkhole automatic health check.
#
# Prerequisites:
#   - run as root inside SINKHOLE-LAB;
#   - curl, jq, iproute2 and systemd available;
#   - service installed as tio-sinkhole.service;
#   - LAB interface named enp2s0 with 10.10.10.30/24.
#
# Side effects:
#   - generates one valid GET, one invalid GET and one rejected POST;
#   - therefore appends three controlled events to requests.jsonl.
#
# Exit codes:
#   0 = all checks passed
#   1 = one or more checks failed

set -uo pipefail

SERVICE_NAME="tio-sinkhole"
SERVICE_USER="tio-sinkhole"

LISTEN_ADDRESS="10.10.10.30"
LISTEN_PORT="8080"
LAB_INTERFACE="enp2s0"
LAB_NETWORK="10.10.10.0/24"

BASE_URL="http://${LISTEN_ADDRESS}:${LISTEN_PORT}"
LOG_FILE="/var/log/tio-sinkhole/requests.jsonl"

PASS_COUNT=0
FAIL_COUNT=0

# curl stores response bodies here so jq can validate them.
HEARTBEAT_BODY="$(mktemp)"
NOT_FOUND_BODY="$(mktemp)"
trap 'rm -f "$HEARTBEAT_BODY" "$NOT_FOUND_BODY"' EXIT

pass() {
    printf '[PASS] %s\n' "$1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    printf '[FAIL] %s\n' "$1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

printf '%s\n' '============================================================'
printf '%s\n' ' TIO Sinkhole - verifica automatica'
printf '%s\n' '============================================================'

# ---------------------------------------------------------------------------
# 1. systemd service state
# ---------------------------------------------------------------------------

if systemctl is-active --quiet "$SERVICE_NAME"; then
    pass "Servizio ${SERVICE_NAME} attivo"
else
    fail "Servizio ${SERVICE_NAME} non attivo"
fi

if systemctl is-enabled --quiet "$SERVICE_NAME"; then
    pass "Servizio ${SERVICE_NAME} abilitato all'avvio"
else
    fail "Servizio ${SERVICE_NAME} non abilitato all'avvio"
fi

# ---------------------------------------------------------------------------
# 2. TCP listener
# ---------------------------------------------------------------------------

if ss -lntH |
    awk -v endpoint="${LISTEN_ADDRESS}:${LISTEN_PORT}" \
        '$4 == endpoint { found=1 } END { exit !found }'
then
    pass "Servizio in ascolto su ${LISTEN_ADDRESS}:${LISTEN_PORT}"
else
    fail "Nessun listener su ${LISTEN_ADDRESS}:${LISTEN_PORT}"
fi

if ss -lntH |
    awk -v endpoint="0.0.0.0:${LISTEN_PORT}" \
        '$4 == endpoint { found=1 } END { exit !found }'
then
    fail "La porta ${LISTEN_PORT} ascolta su tutte le interfacce IPv4"
else
    pass "Nessun ascolto globale su 0.0.0.0:${LISTEN_PORT}"
fi

# ---------------------------------------------------------------------------
# 3. Positive test: GET /heartbeat
# ---------------------------------------------------------------------------

HEARTBEAT_CODE="$(
    curl \
        --silent \
        --show-error \
        --output "$HEARTBEAT_BODY" \
        --write-out '%{http_code}' \
        "${BASE_URL}/heartbeat"
)" || HEARTBEAT_CODE="curl-error"

if [[ "$HEARTBEAT_CODE" == "200" ]]; then
    pass 'GET /heartbeat restituisce HTTP 200'
else
    fail "GET /heartbeat restituisce ${HEARTBEAT_CODE}"
fi

if jq -e '
    .status == "ok"
    and .service == "tio-sinkhole"
    and (.timestamp_utc | type == "string")
' "$HEARTBEAT_BODY" >/dev/null 2>&1
then
    pass 'Risposta /heartbeat contiene JSON valido'
else
    fail 'Risposta /heartbeat non conforme'
fi

# ---------------------------------------------------------------------------
# 4. Negative test: unknown path
# ---------------------------------------------------------------------------

NOT_FOUND_CODE="$(
    curl \
        --silent \
        --show-error \
        --output "$NOT_FOUND_BODY" \
        --write-out '%{http_code}' \
        "${BASE_URL}/percorso-inesistente"
)" || NOT_FOUND_CODE="curl-error"

if [[ "$NOT_FOUND_CODE" == "404" ]]; then
    pass 'Percorso inesistente restituisce HTTP 404'
else
    fail "Percorso inesistente restituisce ${NOT_FOUND_CODE}"
fi

if jq -e '
    .status == "error"
    and .message == "not found"
' "$NOT_FOUND_BODY" >/dev/null 2>&1
then
    pass 'Risposta 404 contiene JSON valido'
else
    fail 'Risposta 404 non conforme'
fi

# ---------------------------------------------------------------------------
# 5. Negative test: POST must be rejected
# ---------------------------------------------------------------------------

POST_CODE="$(
    curl \
        --silent \
        --show-error \
        --output /dev/null \
        --write-out '%{http_code}' \
        --request POST \
        --data 'test=blocked' \
        "${BASE_URL}/heartbeat"
)" || POST_CODE="curl-error"

if [[ "$POST_CODE" == "405" ]]; then
    pass 'POST /heartbeat rifiutato con HTTP 405'
else
    fail "POST /heartbeat restituisce ${POST_CODE}"
fi

# ---------------------------------------------------------------------------
# 6. Non-root process identity
# ---------------------------------------------------------------------------

MAIN_PID="$(
    systemctl show \
        --property MainPID \
        --value "$SERVICE_NAME"
)"

PROCESS_USER="$(
    ps \
        --no-headers \
        --format user= \
        --pid "$MAIN_PID" |
    xargs
)"

if [[ "$PROCESS_USER" == "$SERVICE_USER" ]]; then
    pass "Processo eseguito come ${SERVICE_USER}"
else
    fail "Processo eseguito come ${PROCESS_USER:-utente-sconosciuto}"
fi

# ---------------------------------------------------------------------------
# 7. JSONL integrity and expected last event
# ---------------------------------------------------------------------------

if [[ -s "$LOG_FILE" ]]; then
    if jq -e . "$LOG_FILE" >/dev/null 2>&1; then
        pass 'Log corrente contiene JSONL valido'
    else
        fail 'Log corrente contiene almeno una riga JSON non valida'
    fi
else
    fail 'Log corrente assente o vuoto'
fi

# The rejected POST is the last request produced by this script.
if tail -n 1 "$LOG_FILE" |
    jq -e '
        .method == "POST"
        and .path == "/heartbeat"
        and .status == 405
    ' >/dev/null 2>&1
then
    pass 'Ultimo evento POST/405 registrato nel log'
else
    fail 'Ultimo evento atteso non trovato nel log'
fi

# ---------------------------------------------------------------------------
# 8. Network isolation
# ---------------------------------------------------------------------------

if ip route | grep -q '^default '; then
    fail 'È presente una route predefinita verso reti esterne'
else
    pass 'Nessuna route predefinita: egress bloccato'
fi

if ip route |
    grep -Eq "^${LAB_NETWORK//./\\.} dev ${LAB_INTERFACE}([[:space:]]|$)"
then
    pass "Route interna ${LAB_NETWORK} presente su ${LAB_INTERFACE}"
else
    fail "Route interna ${LAB_NETWORK} non trovata su ${LAB_INTERFACE}"
fi

# ---------------------------------------------------------------------------
# 9. Log rotation timer
# ---------------------------------------------------------------------------

if systemctl is-active --quiet logrotate.timer; then
    pass 'Timer logrotate attivo'
else
    fail 'Timer logrotate non attivo'
fi

if systemctl is-enabled --quiet logrotate.timer; then
    pass 'Timer logrotate abilitato'
else
    fail 'Timer logrotate non abilitato'
fi

# ---------------------------------------------------------------------------
# Final summary
# ---------------------------------------------------------------------------

printf '%s\n' '------------------------------------------------------------'
printf 'Controlli superati: %d\n' "$PASS_COUNT"
printf 'Controlli falliti: %d\n' "$FAIL_COUNT"
printf '%s\n' '------------------------------------------------------------'

if (( FAIL_COUNT > 0 )); then
    printf '%s\n' 'RISULTATO: FAIL'
    exit 1
fi

printf '%s\n' 'RISULTATO: PASS'
exit 0
