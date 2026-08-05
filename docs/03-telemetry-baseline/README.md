# 03 — Baseline di telemetria

**Stato:** `IN PROGRESS`  
**Checkpoint:** `ENV-2026-06 — telemetria multi-sorgente isolata`  
**Prossimo gate:** APPLIANCE-LAB con auditd e Wazuh FIM

## Stato delle sorgenti

| Sorgente | Stato | Nota |
|---|---|---|
| Sinkhole HTTP JSONL | VALIDATED | eventi 200/404/405 acquisiti e ricercabili |
| Wazuh manager/indexer/dashboard | VALIDATED per checkpoint | pipeline Linux + Windows senza egress |
| Wazuh Agent Linux sinkhole | VALIDATED | agent `001` Active tramite `lab-lan` |
| Wazuh Agent Windows | VALIDATED | agent `002` Active tramite `lab-lan` |
| Sysmon Windows | VALIDATED per baseline LAB | processi, file, rete, registro, ADS e DNS osservati |
| PowerShell Operational | VALIDATED | Script Block Logging Event ID 4104 |
| Task Scheduler Operational | VALIDATED | ciclo create/run/delete osservato |
| Security 4698/4699 | PARTIAL VALIDATED | 4698 in Wazuh; 4699 verificato localmente |
| auditd Linux | NOT STARTED | richiede APPLIANCE-LAB |
| Wazuh FIM appliance | NOT STARTED | richiede APPLIANCE-LAB |

## Pipeline multi-sorgente validata

```text
WIN11-LAB
  -> Sysmon / PowerShell / Task Scheduler / Security
  -> Wazuh Agent
  -> Wazuh Manager
  -> alerts.json
  -> Filebeat
  -> Wazuh Indexer
  -> Dashboard

WIN11-LAB
  -> HTTP verso SINKHOLE-LAB:8080
  -> requests.jsonl
  -> Wazuh Agent Linux
  -> stessa pipeline Wazuh
```

WIN11-LAB, SINKHOLE-LAB e WAZUH-LAB sono collegate esclusivamente a `lab-lan`, senza default route durante il test finale.

## Sincronizzazione temporale

L'host Ubuntu distribuisce NTP sulla rete LAB tramite `10.10.10.1:123/udp`.

| Nodo | Client temporale | Sorgente |
|---|---|---|
| WIN11-LAB | `W32Time` | `10.10.10.1,0x8` |
| SINKHOLE-LAB | `systemd-timesyncd` | `10.10.10.1` |
| WAZUH-LAB | `systemd-timesyncd` | `10.10.10.1` |

`chronyc clients` ha confermato richieste reali da `10.10.10.20`, `10.10.10.30` e `10.10.10.40`.

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

Il filtro FileCreate è stato esteso a `C:\Lab\`.

Test selettivo:

- file sotto `C:\Lab\` → un evento Sysmon ID 11;
- file esterno ai path monitorati → zero eventi ID 11.

### PowerShell

- canale Operational abilitato;
- Script Block Logging attivo;
- Event ID `4104` osservato localmente e in Wazuh;
- marker di test rilevato dalla rule `109910`.

### Task Scheduler e Security

Una task temporanea eseguita come `SYSTEM` ha prodotto:

- registrazione task;
- avvio dell'istanza;
- avvio di `cmd.exe`;
- avvio e completamento azione;
- completamento task con codice `0`;
- Sysmon ID `11` per il marker creato;
- Security Event ID `4698`;
- eliminazione e cleanup della task.

## Dataset sintetico

Il dataset contiene esclusivamente dati fittizi sotto `C:\Lab\Synthetic`.

Verifica rispetto a `manifest-sha256.csv`:

| Indicatore | Valore |
|---|---:|
| file attesi | 27 |
| file presenti | 27 |
| file invariati | 27 |
| modificati | 0 |
| mancanti | 0 |
| inattesi | 0 |
| esito | PASS |

## Smoke test NAT-less

Dopo la rimozione della NIC NAT da WIN11-LAB sono stati osservati:

| Sorgente | Event ID / rule | Risultato |
|---|---|---|
| Sysmon | `1` / `92004` | processo con marker finale |
| PowerShell | `4104` / `109910` | marker Script Block Logging |
| Task Scheduler | `106` / `67014` | task registrata |
| Security | `4698` / `60228` | task creata |
| Task Scheduler | `141` / `67015` | task eliminata |
| Sinkhole | HTTP 404 / `100102` | `/final-natless-check` da `10.10.10.20` |

Gli alert sono stati verificati nel file JSON del manager e in Threat Hunting.

## Baseline e snapshot

Sono stati creati pacchetti privati con manifesti SHA-256 e snapshot a VM spenta:

- `WIN11-TELEMETRY-READY`;
- `WAZUH-TELEMETRY-READY`;
- `SINKHOLE-TELEMETRY-READY`.

I pacchetti privati includono inventari, stato servizi, configurazioni o hash, alert ridotti e metadati snapshot. Nel repository pubblico resta soltanto l'evidenza sanificata.

## Controlli completati

- parsing JSON del sinkhole;
- acquisizione EventChannel Windows;
- timestamp UTC coerenti;
- test positivo e negativo Sysmon FileCreate;
- task headless e correlazione tra sensori;
- dataset sintetico e integrità della baseline;
- rimozione NAT e zero default route;
- comunicazione endpoint → Wazuh e endpoint → sinkhole;
- visualizzazione degli alert nel dashboard;
- cleanup degli artefatti temporanei;
- snapshot per singolo nodo.

## Cosa manca per LOGGING-READY

1. APPLIANCE-LAB;
2. auditd e Wazuh FIM;
3. retention finale;
4. matrice formale TP/TN completa;
5. metriche di latency, coverage, precision e data quality;
6. ripetizione completa dopo rollback;
7. snapshot globali `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Gap da dichiarare

- il sinkhole registra la richiesta HTTP, non l'intento del processo che l'ha generata;
- l'indirizzo IP identifica il nodo, non necessariamente l'utente o il processo;
- un singolo 404, 405 o marker non dimostra attività malevola;
- Sysmon non vede tutte le letture di file sensibili;
- accessi a browser store richiedono 4663, FIM, EDR o telemetria dedicata;
- token theft, DPAPI e AMSI bypass non hanno un singolo evento universale;
- la regola `109910` è una regola di validazione della pipeline, non una detection di produzione;
- retention finale, metriche e rollback restano da completare.

Evidenza: [`../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md).
