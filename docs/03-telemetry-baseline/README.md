# 03 - Baseline di telemetria

**Stato:** `IN PROGRESS`  
**Checkpoint:** `ENV-2026-05 — pipeline Wazuh ↔ sinkhole isolata`  
**Prossimo gate:** telemetria Windows da WIN11-LAB

## Stato delle sorgenti

| Sorgente | Stato | Nota |
|---|---|---|
| Sinkhole HTTP JSONL | VALIDATED | eventi 200/404/405 acquisiti e ricercabili |
| Wazuh manager/indexer/dashboard | VALIDATED per pipeline Linux/JSONL | WAZUH-LAB isolata su `10.10.10.40` |
| Wazuh Agent Linux sinkhole | VALIDATED | agent Active tramite `lab-lan` |
| Sysmon Windows | NOT STARTED | richiede WIN11-LAB |
| PowerShell Operational | NOT STARTED | richiede WIN11-LAB |
| Security 4698/4699 | NOT STARTED | richiede policy audit Windows |
| auditd Linux | NOT STARTED | richiede APPLIANCE-LAB |
| Wazuh FIM appliance | NOT STARTED | richiede APPLIANCE-LAB |

## Pipeline Linux/JSONL validata

```text
client LAB
  -> SINKHOLE-LAB:8080
  -> /var/log/tio-sinkhole/requests.jsonl
  -> Wazuh Agent
  -> Wazuh Manager
  -> alerts.json
  -> Filebeat
  -> Wazuh Indexer
  -> Dashboard
```

SINKHOLE-LAB e WAZUH-LAB sono collegate esclusivamente a `lab-lan`, senza default route. Dopo la rimozione della NAT da WAZUH-LAB, i servizi Wazuh, l'agent e gli alert 200/404/405 sono stati verificati nuovamente.

## Sorgente sinkhole

Percorso nella VM:

```text
/var/log/tio-sinkhole/requests.jsonl
```

Schema validato:

| Campo | Tipo | Uso |
|---|---|---|
| `timestamp_utc` | stringa ISO 8601 | timeline e ordinamento |
| `client_ip` | stringa IPv4 | nodo origine nella rete LAB |
| `method` | stringa | GET, HEAD o metodo rifiutato |
| `path` | stringa | endpoint richiesto |
| `query` | stringa | query string limitata |
| `user_agent` | stringa | client o identificatore del test |
| `status` | numero | esito HTTP 200, 404 o 405 |

Esempio sanificato:

```json
{
  "timestamp_utc": "<ISO-8601 UTC>",
  "client_ip": "10.10.10.1",
  "method": "GET",
  "path": "/heartbeat",
  "query": "",
  "user_agent": "<client>",
  "status": 200
}
```

## Configurazione dell'agent

Il Wazuh Agent su SINKHOLE-LAB segue il JSONL con `log_format` impostato a `json` e aggiunge:

```text
@source = tio-sinkhole
lab.role = sinkhole
```

Il log interno dell'agent ha confermato:

```text
Analyzing file: '/var/log/tio-sinkhole/requests.jsonl'
```

Configurazioni:

- [`../../configs/sinkhole/server.py`](../../configs/sinkhole/server.py)
- [`../../configs/sinkhole/tio-sinkhole.service`](../../configs/sinkhole/tio-sinkhole.service)
- [`../../configs/sinkhole/tio-sinkhole.logrotate`](../../configs/sinkhole/tio-sinkhole.logrotate)
- [`../../configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml`](../../configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml)

Evidenza: [`../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`](../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md).

## Controlli completati

- lettura del JSONL da parte dell'agent;
- parsing dei campi JSON senza regex sul messaggio completo;
- conservazione del timestamp UTC originale;
- distinzione tra 200, 404 e 405;
- ricerca per Rule ID e campi strutturati;
- rotazione del file senza bloccare la scrittura corrente;
- agent Active dopo la rimozione della NAT;
- pipeline ripetuta con WAZUH-LAB priva di egress;
- snapshot `WAZUH-PIPELINE-READY` creato a VM spenta.

## Smoke test completo

La componente Linux/JSONL è validata. Per raggiungere `LOGGING-READY` restano:

1. process creation e command line da WIN11-LAB;
2. file marker da Sysmon 11 o FIM;
3. richiesta heartbeat dal nodo Windows;
4. eventi Sysmon, PowerShell e auditing nel dashboard;
5. telemetria auditd/FIM dell'appliance;
6. cleanup e test negativi;
7. ripetizione dopo rollback.

## Gap da dichiarare

- il sinkhole registra la richiesta HTTP, non l'intento del processo che l'ha generata;
- l'indirizzo IP identifica il nodo, non necessariamente l'utente o il processo;
- il formato corrente non contiene `request_id` o `exercise_id` dedicati;
- un singolo 404 o 405 non dimostra attività malevola;
- Sysmon non vede tutte le letture di file sensibili;
- accessi a browser store richiedono 4663, FIM, EDR o telemetria dedicata;
- token theft, DPAPI e AMSI bypass non hanno un singolo evento universale;
- il servizio NTP esterno non è raggiungibile senza egress; serve una sorgente temporale interna;
- retention finale, test negativi, metriche e rollback restano da completare.
