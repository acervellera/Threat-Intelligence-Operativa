# 03 — Baseline di telemetria

**Stato:** `IN PROGRESS`  
**Checkpoint:** `ENV-2026-09 — matrice formale TP/TN multi-nodo`  
**Retention finale:** `PASS`  
**Prossimo gate:** metriche, smoke test coordinato e rollback

## Stato delle sorgenti

| Sorgente | Stato | Nota |
|---|---|---|
| Sinkhole HTTP JSONL | VALIDATED | eventi 200/404/405 acquisiti e ricercabili |
| Wazuh manager/indexer/dashboard | VALIDATED per checkpoint | pipeline multi-sorgente senza egress |
| Wazuh Agent Linux sinkhole | VALIDATED | agent `001` Active tramite `lab-lan` |
| Wazuh Agent Windows | VALIDATED | agent `002` Active tramite `lab-lan` |
| Wazuh Agent Linux appliance | VALIDATED | agent `003` Active tramite `lab-lan` |
| Sysmon Windows | VALIDATED per baseline LAB | processi, file, rete, registro, ADS e DNS osservati |
| PowerShell Operational | VALIDATED | Script Block Logging 4104; TP/TN formale completato |
| Task Scheduler Operational | VALIDATED | create/delete correlati con Wazuh |
| Security 4698 | VALIDATED | rule `60228` |
| Security 4699 | OBSERVED / DISCOVERY | osservato localmente; alert Wazuh non osservato |
| auditd Linux appliance | VALIDATED | `tio_appliance_exec -> 80789`, TP/TN completato |
| Wazuh FIM appliance | VALIDATED | added/modified/deleted Whodata e TN fuori path |
| retention | VALIDATED | `ENV-2026-08` |

## Pipeline multi-sorgente

```text
WIN11-LAB
  -> Sysmon / PowerShell / Task Scheduler / Security
  -> Wazuh Agent 002
  -> Wazuh Manager

SINKHOLE-LAB
  -> requests.jsonl
  -> Wazuh Agent 001
  -> Wazuh Manager

APPLIANCE-LAB
  -> auditd / FIM Whodata
  -> Wazuh Agent 003
  -> Wazuh Manager

Wazuh Manager
  -> alerts.json -> Filebeat -> Indexer -> Dashboard
```

I quattro nodi principali sono collegati esclusivamente a `lab-lan` durante i test finali, senza default route.

## Sincronizzazione temporale

L'host Ubuntu distribuisce NTP sulla rete LAB tramite `10.10.10.1:123/udp`. WIN11-LAB usa W32Time; i nodi Linux usano il client temporale di sistema. I timestamp UTC dei quattro nodi sono stati verificati come coerenti.

## Windows

Canali acquisiti:

```text
Microsoft-Windows-Sysmon/Operational
Microsoft-Windows-PowerShell/Operational
Microsoft-Windows-TaskScheduler/Operational
Security
System
Application
```

### PowerShell

Il marker benigno ha prodotto:

```text
PowerShell Event 4104 -> Wazuh rule 109910
```

Il TN con un 4104 benigno senza marker ha prodotto `109910 = 0`.

Durante il TP, comandi diagnostici contenenti letteralmente il trigger hanno generato ulteriori 4104 e alert `109910`. Gli alert del test harness sono stati separati dall'evento intenzionale tramite Record ID / ScriptBlock ID e il metodo è stato corretto.

### Scheduled Task e Security

La creazione di una Scheduled Task benigna ha prodotto due viste indipendenti:

```text
TaskScheduler 106 -> Wazuh 67014
Security 4698     -> Wazuh 60228
```

Il cleanup ha prodotto:

```text
TaskScheduler 141 -> Wazuh 67015
Security 4699     -> osservato localmente
```

Non è stato osservato un alert Wazuh per il 4699. Con `logall/logall_json` disabilitati non è possibile dimostrare dal manager la persistenza del singolo evento non allertante.

## Sinkhole

Schema JSONL validato con timestamp, client IP, metodo, path, user-agent e status. La matrice formale ha verificato:

| HTTP | Rule | Esito |
|---|---:|---|
| heartbeat 200 | `100101` | PASS |
| unknown path 404 | `100102` | PASS |
| POST / heartbeat 405 | `100103` | PASS |
| heartbeat vs 404 | nessuna `100102` | PASS |
| heartbeat vs 405 | nessuna `100103` | PASS |

## Auditd su APPLIANCE-LAB

Componenti:

```text
auditd
audispd-plugins
/var/log/audit/audit.log
```

La watch di esecuzione:

```text
-w /opt/tio-appliance-lab/bin/tio-marker.sh -p x -k tio_appliance_exec
```

ha prodotto un evento `execve success=yes` con chiave `tio_appliance_exec` e Wazuh rule `80789`. Il TN con attività benigna fuori dalla watch ha prodotto `80789 = 0`.

Il mapping manager è pubblicato in `configs/wazuh/lists/tio-audit-keys.txt`.

## Wazuh FIM Whodata

Percorso monitorato:

```text
/opt/tio-appliance-lab/data
```

Configurazione:

```text
check_all=yes
realtime=yes
whodata=yes
report_changes=yes
```

Ciclo formale:

| Operazione | Rule | Evento | Esito |
|---|---:|---|---|
| creazione | `554` | `added` | PASS |
| modifica contenuto | `550` | `modified` | PASS |
| file fuori path | nessuna target | TN | PASS |
| cleanup | `553` | `deleted` | PASS |

Whodata ha incluso utente e processo; la modifica ha esposto SHA-256 precedente e successivo.

## Retention finale — ENV-2026-08

- WAZUH-LAB: alert rotation verificata, `logall=no`, `logall_json=no`;
- SINKHOLE-LAB: logrotate giornaliero, 14 rotazioni, maxsize 10 MiB, compressione;
- APPLIANCE-LAB: auditd con `max_log_file=8 MiB`, `num_logs=5` e rotazione;
- WIN11-LAB: Security/Sysmon 128 MiB, PowerShell 64 MiB, TaskScheduler/System 32 MiB, modalità circolare.

Dettaglio pubblico: `../../evidence/sanitized/ENV-2026-08-retention-baseline.md`.

## Matrice formale — ENV-2026-09

La matrice contiene 14 test, 8 TP e 6 TN, tutti PASS. Le raw evidence sono conservate privatamente per sorgente; la matrice finale è stata congelata e il manifesto SHA-256 finale verificato.

Dettaglio pubblico: `../../evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md`.

## Gap dichiarati

- il sinkhole registra richieste HTTP, non l'intento del processo;
- Sysmon e FIM non equivalgono a una registrazione completa di tutte le operazioni;
- `109910`, `80789` e le regole sinkhole sono controlli LAB, non detection di produzione;
- con `logall/logall_json` disabilitati, un evento non allertante può non essere persistito nel manager;
- metriche formali e repeatability dopo rollback restano da completare.

## Cosa manca per LOGGING-READY

1. metriche di latency, coverage, precision, data quality e repeatability;
2. smoke test coordinato dei quattro nodi;
3. ripetizione completa dopo rollback;
4. verifica globale cleanup e baseline;
5. inventario snapshot;
6. snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Evidenze

- `../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`
- `../../evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md`
- `../../evidence/sanitized/ENV-2026-08-retention-baseline.md`
- `../../evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md`
