# 03 - Baseline di telemetria

**Stato:** `IN PROGRESS`, limitatamente alla sorgente sinkhole  
**Checkpoint:** `ENV-2026-04 — SINKHOLE-READY`  
**Prossimo gate:** ingestione del JSONL in Wazuh

## Stato delle sorgenti

| Sorgente | Stato | Nota |
|---|---|---|
| Sinkhole HTTP JSONL | READY | eventi 200/404/405 generati e validati |
| Wazuh manager/indexer/dashboard | NOT STARTED | prossimo nodo `10.10.10.40` |
| Sysmon Windows | NOT STARTED | richiede WIN11-LAB |
| PowerShell Operational | NOT STARTED | richiede WIN11-LAB |
| Security 4698/4699 | NOT STARTED | richiede policy audit Windows |
| auditd Linux | NOT STARTED | richiede APPLIANCE-LAB |
| Wazuh FIM | NOT STARTED | richiede manager e agent |

## Eventi prioritari

| Fonte | Evento | Uso | Limite |
|---|---|---|---|
| Sinkhole JSONL | richiesta HTTP | heartbeat, client, metodo, path e status | non dimostra intento o contenuto eseguito |
| Sysmon | 1 Process Create | process tree, command line, hash, parent | non prova l'intento |
| Sysmon | 3 Network Connect | connessioni verso sinkhole | può essere filtrato per volume |
| Sysmon | 11 File Create | Startup, staging, extension, marker | non registra ogni lettura |
| Sysmon | 12-14 Registry | Run key, service e policy | richiede filtri mirati |
| Sysmon | 15 FileCreateStreamHash | ADS nel caso WinRAR | non prova lo sfruttamento |
| Sysmon | 22 DNS Query | nomi LAB e periodicità | DoH applicativo può sfuggire |
| PowerShell | 4104 | contenuto script e decodifica | può contenere dati sensibili |
| Security | 4698/4699 | create/delete scheduled task | richiede auditing avanzato |
| System | 7045 | creazione servizio | contesto utente limitato |
| Wazuh FIM/auditd | file integrity / execve | appliance Linux | tuning indispensabile |

## Sorgente sinkhole pronta

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
| `user_agent` | stringa | client o strumento usato |
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

Configurazioni:

- [`../../configs/sinkhole/server.py`](../../configs/sinkhole/server.py)
- [`../../configs/sinkhole/tio-sinkhole.service`](../../configs/sinkhole/tio-sinkhole.service)
- [`../../configs/sinkhole/tio-sinkhole.logrotate`](../../configs/sinkhole/tio-sinkhole.logrotate)

Evidenza: [`../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md`](../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md).

## Parsing Wazuh pianificato

Il prossimo checkpoint deve dimostrare:

1. lettura del file JSONL da parte dell'agent o del manager;
2. un evento Wazuh per ogni riga JSON;
3. campi accessibili senza parsing fragile del messaggio completo;
4. conservazione del timestamp UTC originale;
5. distinzione tra 200, 404 e 405;
6. ricerca per `client_ip`, `method`, `path` e `status`;
7. rotazione senza perdita o duplicazione evidente degli eventi.

La configurazione Wazuh non viene pubblicata prima di questi controlli.

## Smoke test

La pipeline sarà valida quando:

1. un processo di prova appare in Sysmon;
2. un file marker appare in Sysmon 11 o FIM;
3. una richiesta heartbeat appare nel sinkhole;
4. il JSONL del sinkhole raggiunge Wazuh;
5. l'evento endpoint raggiunge Wazuh con `agent.name`, Event ID e command line;
6. il cleanup rimuove il marker;
7. la stessa prova è ripetibile dopo rollback.

Il punto 3 è già validato. I punti relativi a Wazuh ed endpoint restano da completare.

## Gap da dichiarare

- il sinkhole registra la richiesta HTTP, non l'intento del processo che l'ha generata;
- l'indirizzo IP identifica il nodo, non necessariamente l'utente o il processo;
- il formato corrente non contiene `request_id` o `exercise_id`;
- Sysmon non vede tutte le letture di file sensibili;
- accessi a browser store richiedono 4663, FIM, EDR o telemetria dedicata;
- token theft, DPAPI e AMSI bypass non hanno un singolo evento universale;
- appliance richiedono log centralizzati, auditd, FIM e rete.
