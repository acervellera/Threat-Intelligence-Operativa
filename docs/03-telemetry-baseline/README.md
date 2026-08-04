# 03 - Baseline di telemetria

**Stato:** `IN PROGRESS`  
**Checkpoint:** `ENV-2026-05 — pipeline Wazuh ↔ sinkhole`  
**Prossimo gate:** telemetria Windows e appliance, quindi `LOGGING-READY`

## Stato delle sorgenti

| Sorgente | Stato | Nota |
|---|---|---|
| Sinkhole HTTP JSONL | VALIDATED | eventi 200/404/405 generati, raccolti e ricercabili |
| Wazuh manager/indexer/dashboard | VALIDATED per pipeline Linux | servizi attivi, indexer green, dashboard operativo |
| Wazuh Agent Linux | VALIDATED | `sinkhole-lab` Active tramite `lab-lan` |
| Sysmon Windows | NOT STARTED | richiede WIN11-LAB |
| PowerShell Operational | NOT STARTED | richiede WIN11-LAB |
| Security 4698/4699 | NOT STARTED | richiede policy audit Windows |
| auditd Linux | NOT STARTED | richiede APPLIANCE-LAB |
| Wazuh FIM | NOT STARTED | pianificato per endpoint e appliance |

## Pipeline validata

```text
SINKHOLE-LAB
  /var/log/tio-sinkhole/requests.jsonl
      -> wazuh-logcollector
      -> Wazuh Agent
      -> WAZUH-LAB manager
      -> regole custom
      -> alerts.json
      -> Filebeat
      -> Wazuh Indexer
      -> Wazuh Dashboard
```

SINKHOLE-LAB comunica con il manager su `10.10.10.40:1514/tcp` senza NIC NAT e senza default route.

## Schema JSONL

Percorso:

```text
/var/log/tio-sinkhole/requests.jsonl
```

| Campo | Tipo | Uso |
|---|---|---|
| `timestamp_utc` | stringa ISO 8601 | timeline e ordinamento |
| `client_ip` | stringa IPv4 | nodo origine nella rete LAB |
| `method` | stringa | metodo HTTP |
| `path` | stringa | endpoint richiesto |
| `query` | stringa | query string limitata |
| `user_agent` | stringa | client o ID del test |
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

## Configurazione Wazuh Agent

Il frammento validato è pubblicato in:

- [`../../configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml`](../../configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml)

Il blocco usa:

```xml
<log_format>json</log_format>
<label key="@source">tio-sinkhole</label>
<label key="lab.role">sinkhole</label>
```

Validazioni eseguite:

- `wazuh-logcollector -t` senza errori;
- `wazuh-agentd -t` senza errori;
- riavvio di `wazuh-agent`;
- agent ancora `Active`;
- log interno con `Analyzing file: '/var/log/tio-sinkhole/requests.jsonl'`;
- nuovi eventi raccolti dopo il riavvio;
- logrotate continua a creare il file corrente con proprietario e permessi corretti.

## Regole tecniche della baseline

| Rule ID | Livello | Condizione |
|---:|---:|---|
| `100101` | 3 | heartbeat con status 200 e path `/heartbeat` |
| `100102` | 5 | risposta 404 |
| `100103` | 7 | risposta 405 |

Regole pubblicate:

- [`../../configs/wazuh/rules/tio_sinkhole_rules.xml`](../../configs/wazuh/rules/tio_sinkhole_rules.xml)

La regola padre limita l'ambito agli eventi decodificati come JSON e provenienti da `requests.jsonl`. Il campo `status` è statico nel motore Wazuh ed è confrontato con il tag `<status>`.

## Test end-to-end

| Test | Risposta | Rule ID | Esito |
|---|---:|---:|---|
| `GET /heartbeat` | 200 | `100101` | PASS |
| `GET /tio-live-not-found` | 404 | `100102` | PASS |
| `POST /tio-live-post` | 405 | `100103` | PASS |

Gli alert sono stati verificati nel manager, nell'indexer e nel Threat Hunting del dashboard.

Query DQL:

```text
rule.id:100101 or rule.id:100102 or rule.id:100103
```

## Eventi prioritari futuri

| Fonte | Evento | Uso | Limite |
|---|---|---|---|
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

## Smoke test completo ancora da eseguire

La pipeline Linux/JSONL è validata, ma `LOGGING-READY` richiede ancora:

1. process creation su WIN11-LAB;
2. file marker in Sysmon 11 o FIM;
3. PowerShell 4104 e auditing task;
4. evento endpoint nel dashboard con campi completi;
5. cleanup del marker;
6. test negativo;
7. ripetizione dopo rollback;
8. snapshot finale.

## Gap da dichiarare

- il sinkhole registra la richiesta HTTP, non l'intento del processo;
- l'indirizzo IP identifica il nodo, non necessariamente l'utente o il processo;
- il formato corrente non contiene `request_id` o `exercise_id` dedicati;
- un singolo 404 o 405 non dimostra attività malevola;
- Sysmon non vede tutte le letture di file sensibili;
- accessi a browser store richiedono 4663, FIM, EDR o telemetria dedicata;
- token theft, DPAPI e AMSI bypass non hanno un singolo evento universale;
- la NIC NAT di WAZUH-LAB deve ancora essere rimossa;
- la pipeline non è stata ancora ripetuta dopo rollback.

Evidenza: [`../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`](../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md).
