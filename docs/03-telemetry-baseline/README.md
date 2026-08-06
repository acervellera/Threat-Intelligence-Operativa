# 03 — Baseline di telemetria

**Stato:** `IN PROGRESS`  
**Checkpoint:** `ENV-2026-07 — APPLIANCE-LAB telemetry ready`  
**Prossimo gate:** retention, matrice TP/TN, metriche e rollback coordinato

## Stato delle sorgenti

| Sorgente | Stato | Nota |
|---|---|---|
| Sinkhole HTTP JSONL | VALIDATED | eventi 200/404/405 acquisiti e ricercabili |
| Wazuh manager/indexer/dashboard | VALIDATED per checkpoint | pipeline multi-sorgente senza egress |
| Wazuh Agent Linux sinkhole | VALIDATED | agent `001` Active tramite `lab-lan` |
| Wazuh Agent Windows | VALIDATED | agent `002` Active tramite `lab-lan` |
| Wazuh Agent Linux appliance | VALIDATED | agent `003` Active tramite `lab-lan` |
| Sysmon Windows | VALIDATED per baseline LAB | processi, file, rete, registro, ADS e DNS osservati |
| PowerShell Operational | VALIDATED | Script Block Logging Event ID 4104 |
| Task Scheduler Operational | VALIDATED | ciclo create/run/delete osservato |
| Security 4698/4699 | PARTIAL VALIDATED | 4698 in Wazuh; 4699 verificato localmente |
| auditd Linux appliance | VALIDATED | marker locale e alert rule `80789` |
| Wazuh FIM appliance | VALIDATED | added/modified/deleted Whodata e test negativo |

## Pipeline multi-sorgente validata

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

WIN11-LAB, SINKHOLE-LAB, WAZUH-LAB e APPLIANCE-LAB sono collegate esclusivamente a `lab-lan`, senza default route durante i test finali.

## Sincronizzazione temporale

L'host Ubuntu distribuisce NTP sulla rete LAB tramite `10.10.10.1:123/udp`.

| Nodo | Client temporale | Sorgente |
|---|---|---|
| WIN11-LAB | `W32Time` | `10.10.10.1,0x8` |
| SINKHOLE-LAB | `systemd-timesyncd` | `10.10.10.1` |
| WAZUH-LAB | `systemd-timesyncd` | `10.10.10.1` |
| APPLIANCE-LAB | `systemd-timesyncd` | `10.10.10.1` |

I client `.20`, `.30`, `.40` e `.50` hanno mostrato timestamp UTC coerenti.

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

Configurazioni:

- [`../../configs/sinkhole/server.py`](../../configs/sinkhole/server.py)
- [`../../configs/sinkhole/tio-sinkhole.service`](../../configs/sinkhole/tio-sinkhole.service)
- [`../../configs/sinkhole/tio-sinkhole.logrotate`](../../configs/sinkhole/tio-sinkhole.logrotate)
- [`../../configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml`](../../configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml)

## Sorgenti Windows

Frammenti pubblici:

- [`../../configs/wazuh/windows-eventchannel/tio-windows-eventchannels.xml`](../../configs/wazuh/windows-eventchannel/tio-windows-eventchannels.xml)

Canali acquisiti:

```text
Microsoft-Windows-Sysmon/Operational
Microsoft-Windows-PowerShell/Operational
Microsoft-Windows-TaskScheduler/Operational
Security
System
Application
```

### Sysmon

Eventi osservati durante la validazione:

| Event ID | Contesto |
|---:|---|
| `1` | process creation e command line |
| `3` | connessione verso rete LAB |
| `11` | file creation |
| `13` | modifica registro |
| `15` | alternate data stream / Zone.Identifier |
| `22` | DNS query |

Il filtro FileCreate è stato esteso a `C:\Lab\`. Un file sotto `C:\Lab\` ha prodotto un evento ID 11, mentre un file esterno ai path monitorati non lo ha prodotto.

### PowerShell, Task Scheduler e Security

- Script Block Logging Event ID `4104` osservato localmente e in Wazuh;
- marker rilevato dalla rule `109910`;
- task temporanea come `SYSTEM` correlata con Sysmon;
- Security Event ID `4698`;
- eliminazione e cleanup della task.

## Dataset sintetico Windows

| Indicatore | Valore |
|---|---:|
| file attesi | 27 |
| file presenti | 27 |
| file invariati | 27 |
| modificati | 0 |
| mancanti | 0 |
| inattesi | 0 |
| esito | PASS |

## Auditd su APPLIANCE-LAB

Componenti:

```text
auditd
audispd-plugins
/var/log/audit/audit.log
```

La baseline locale ha verificato servizio active/enabled, kernel audit attivo, `lost=0` e marker benigno ricercabile con `ausearch`.

Regole pubbliche:

- [`../../configs/auditd/70-tio-appliance.rules`](../../configs/auditd/70-tio-appliance.rules)
- [`../../scripts/lab/tio-marker.sh`](../../scripts/lab/tio-marker.sh)

Chiavi finali:

```text
tio_appliance_exec
tio_systemd_changes
```

La directory FIM non mantiene una watch TIO parallela: è gestita dalla watch dinamica `wazuh_fim`.

## Audit execution in Wazuh

Il manager usa il mapping:

```text
tio_appliance_exec:execute
```

Configurazione pubblica:

- [`../../configs/wazuh/lists/tio-audit-keys.txt`](../../configs/wazuh/lists/tio-audit-keys.txt)

L'esecuzione dello script benigno ha prodotto la rule `80789` con:

- `success=yes`;
- chiave `tio_appliance_exec`;
- comando ed executable;
- `auid` e `uid` dell'utente sintetico;
- working directory;
- argomento marker.

## Wazuh FIM Whodata

Percorso monitorato:

```text
/opt/tio-appliance-lab/data
```

Configurazione pubblica:

- [`../../configs/wazuh/linux-fim/tio-appliance-fim.xml`](../../configs/wazuh/linux-fim/tio-appliance-fim.xml)

Opzioni:

```text
check_all=yes
realtime=yes
whodata=yes
report_changes=yes
```

Ciclo validato:

| Operazione | Rule | Evento | Modalità |
|---|---:|---|---|
| creazione | `554` | `added` | `whodata` |
| modifica contenuto | `550` | `modified` | `whodata` |
| modifica permessi | `550` | `modified` | `whodata` |
| cancellazione | `553` | `deleted` | `whodata` |

Tutti i record hanno incluso attribuzione utente/processo. Un file sotto `/var/tmp` ha prodotto zero alert FIM TIO.

### Correzione del conflitto di watch

La prima configurazione applicava sullo stesso percorso:

```text
tio_appliance_files
wazuh_fim
```

Gli eventi venivano associati alla watch personalizzata e il flusso Whodata non completava la classificazione FIM. La watch `tio_appliance_files` è stata rimossa, le regole sono state ricaricate e il ciclo è stato ripetuto con la sola watch dinamica `wazuh_fim`.

## SCA del plugin Audit Wazuh

L'attivazione Whodata ha generato `af_wazuh.conf`. I controlli CIS:

- `35752` — modalità file Audit;
- `35754` — gruppo file Audit;

sono inizialmente passati da passed a failed. Il file è stato corretto a:

```text
mode=0640 owner=root group=root
```

Dopo il restart dell'agent la configurazione è rimasta stabile e una nuova scansione SCA ha registrato `failed -> passed` tramite rule `19010`.

## Smoke test NAT-less

### Windows + sinkhole

| Sorgente | Event ID / rule | Risultato |
|---|---|---|
| Sysmon | `1` / `92004` | processo con marker finale |
| PowerShell | `4104` / `109910` | marker Script Block Logging |
| Task Scheduler | `106` / `67014` | task registrata |
| Security | `4698` / `60228` | task creata |
| Task Scheduler | `141` / `67015` | task eliminata |
| Sinkhole | HTTP 404 / `100102` | `/final-natless-check` da `10.10.10.20` |

### Appliance

Dopo la rimozione della NIC NAT:

- sola `lab-lan` su `10.10.10.50/24`;
- default route assente;
- Internet non raggiungibile;
- NTP `10.10.10.1` sincronizzato;
- agent `003` Active;
- nuovo alert Audit `80789`;
- nuovo ciclo FIM `550/553/554` in modalità Whodata;
- test negativo FIM con zero alert.

## Baseline e snapshot

Sono stati creati pacchetti privati con manifesti SHA-256 e snapshot a VM spenta:

- `WIN11-TELEMETRY-READY`;
- `WAZUH-TELEMETRY-READY`;
- `SINKHOLE-TELEMETRY-READY`;
- `APPLIANCE-TELEMETRY-READY`.

Nel repository pubblico restano soltanto evidenze sanificate e configurazioni ridotte.

## Controlli completati

- parsing JSON sinkhole;
- acquisizione EventChannel Windows;
- raccolta Audit Linux;
- FIM realtime Whodata;
- timestamp UTC coerenti sui quattro nodi;
- test positivi e negativi Windows e Linux;
- dataset sintetico e integrità baseline;
- rimozione NAT e zero default route;
- visualizzazione alert nel manager e dashboard;
- cleanup degli artefatti temporanei;
- snapshot per singolo nodo.

## Cosa manca per LOGGING-READY

1. retention finale;
2. matrice formale TP/TN completa;
3. metriche di latency, coverage, precision e data quality;
4. smoke test coordinato dei quattro nodi;
5. ripetizione completa dopo rollback;
6. verifica globale del cleanup;
7. snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Gap da dichiarare

- il sinkhole registra richieste HTTP, non l'intento del processo;
- l'indirizzo IP identifica il nodo, non necessariamente l'utente;
- marker, 404, 405 e singole modifiche FIM non dimostrano da soli attività malevola;
- Sysmon non vede tutte le letture di file sensibili;
- FIM rileva il cambiamento, ma non sostituisce la telemetria completa di processo e rete;
- la regola `109910` e la rule Audit usata nel checkpoint validano la pipeline, non costituiscono detection di produzione;
- retention, metriche e rollback globale restano da completare.

Evidenze:

- [`../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md)
- [`../../evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md)
