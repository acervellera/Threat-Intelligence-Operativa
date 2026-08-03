# Sinkhole HTTP interno

**Classificazione:** PUBLIC / LAB ONLY  
**Stato:** VALIDATED in `ENV-2026-04`  
**Ambiente testato:** Debian 13, Python 3.13, rete host-only `10.10.10.0/24`

Questa directory contiene la configurazione pubblica del servizio benigno usato per produrre telemetria HTTP controllata.

## File

| File | Destinazione nella VM | Scopo |
|---|---|---|
| [`server.py`](server.py) | `/opt/tio-sinkhole/server.py` | endpoint `/heartbeat` e log JSONL |
| [`tio-sinkhole.service`](tio-sinkhole.service) | `/etc/systemd/system/tio-sinkhole.service` | esecuzione non-root e hardening systemd |
| [`tio-sinkhole.logrotate`](tio-sinkhole.logrotate) | `/etc/logrotate.d/tio-sinkhole` | rotazione e retention dei log |
| [`../../scripts/common/tio-sinkhole-check.sh`](../../scripts/common/tio-sinkhole-check.sh) | `/usr/local/sbin/tio-sinkhole-check` | verifica automatica a 16 controlli |

## Comportamento

Il servizio ascolta esclusivamente su:

```text
10.10.10.30:8080/TCP
```

Matrice HTTP:

| Metodo e percorso | Risposta |
|---|---:|
| `GET /heartbeat` | 200 JSON |
| `HEAD /heartbeat` | 200 senza corpo |
| `GET <altro-percorso>` | 404 JSON |
| `POST`, `PUT`, `PATCH`, `DELETE` | 405 |

Non esistono funzioni di upload, download di payload, esecuzione di comandi o proxy verso Internet.

## Installazione di riferimento

Eseguire dentro una VM LAB già isolata. I comandi richiedono privilegi root.

### 1. Account e directory

```bash
adduser --system --group --no-create-home tio-sinkhole

install -d -o root -g tio-sinkhole -m 0750 /opt/tio-sinkhole
install -d -o tio-sinkhole -g tio-sinkhole -m 0750 /var/log/tio-sinkhole
```

### 2. Applicazione

```bash
install \
  -o root \
  -g tio-sinkhole \
  -m 0640 \
  server.py \
  /opt/tio-sinkhole/server.py
```

Controllo sintattico senza creare `__pycache__` nella directory protetta:

```bash
python3 - <<'PY'
from pathlib import Path

path = Path('/opt/tio-sinkhole/server.py')
compile(path.read_text(encoding='utf-8'), str(path), 'exec')
print('PASS: sintassi Python valida')
PY
```

### 3. systemd

```bash
install \
  -o root \
  -g root \
  -m 0644 \
  tio-sinkhole.service \
  /etc/systemd/system/tio-sinkhole.service

systemd-analyze verify /etc/systemd/system/tio-sinkhole.service
systemctl daemon-reload
systemctl enable --now tio-sinkhole
```

### 4. logrotate

```bash
install \
  -o root \
  -g root \
  -m 0644 \
  tio-sinkhole.logrotate \
  /etc/logrotate.d/tio-sinkhole

logrotate --debug /etc/logrotate.d/tio-sinkhole
```

Il file sotto `/etc/logrotate.d` deve essere `root:root` e non scrivibile dal gruppo o da altri. Una modalità come `0664` viene rifiutata da `logrotate`; la modalità validata è `0644`.

### 5. Health check

```bash
install \
  -o root \
  -g root \
  -m 0750 \
  ../../scripts/common/tio-sinkhole-check.sh \
  /usr/local/sbin/tio-sinkhole-check

bash -n /usr/local/sbin/tio-sinkhole-check
/usr/local/sbin/tio-sinkhole-check
```

Risultato atteso:

```text
Controlli superati: 16
Controlli falliti: 0
RISULTATO: PASS
```

## Verifiche manuali

```bash
systemctl is-active tio-sinkhole
systemctl is-enabled tio-sinkhole
ss -lntp | grep ':8080'

curl -sS http://10.10.10.30:8080/heartbeat | jq
curl -sS -o /dev/null -w '%{http_code}\n' http://10.10.10.30:8080/inesistente
curl -sS -o /dev/null -w '%{http_code}\n' -X POST -d 'test=blocked' http://10.10.10.30:8080/heartbeat
```

Codici attesi:

```text
200
404
405
```

## Log e correlazione

Il file:

```text
/var/log/tio-sinkhole/requests.jsonl
```

contiene una riga JSON per richiesta. I campi disponibili sono:

- `timestamp_utc`;
- `client_ip`;
- `method`;
- `path`;
- `query`;
- `user_agent`;
- `status`.

La correlazione iniziale avviene tramite tempo, client, metodo, percorso e codice HTTP. L'aggiunta di `request_id` o `exercise_id` è pianificata, ma non appartiene al comportamento validato in questo checkpoint.

## Rotazione

Politica validata:

- valutazione giornaliera;
- retention di 14 archivi;
- rotazione anticipata a 10 MiB;
- compressione degli archivi più vecchi;
- nuovo file `0640 tio-sinkhole:tio-sinkhole`;
- nessun riavvio del servizio necessario.

## Rollback

Per rimuovere il servizio senza cancellare immediatamente le evidenze:

```bash
systemctl disable --now tio-sinkhole
rm -f /etc/systemd/system/tio-sinkhole.service
rm -f /etc/logrotate.d/tio-sinkhole
systemctl daemon-reload
```

Conservare o sanificare i log secondo la policy del laboratorio prima di rimuovere `/var/log/tio-sinkhole`.

Per un rollback completo e ripetibile usare lo snapshot precedente `CLEAN-OS`.

## Limiti

- indirizzo e interfaccia sono statici per la topologia TIO;
- non è presente autenticazione, perché il servizio è limitato alla rete host-only;
- non è un honeypot esposto a Internet;
- non sostituisce un reverse proxy o un server HTTP production-grade;
- la raccolta Wazuh non è ancora inclusa in questo checkpoint.

Evidenza collegata: [`../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md`](../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md).
