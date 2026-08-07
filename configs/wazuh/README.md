# Configurazioni Wazuh validate

Questa directory contiene copie pubbliche e ridotte delle configurazioni validate nel laboratorio. Non include password, certificati privati, chiavi agent, UUID, MAC address o output raw.

## Stato

| Area | File | Stato | Checkpoint |
|---|---|---|---|
| Agent Linux sinkhole | [`linux-localfile/tio-sinkhole-jsonl.xml`](linux-localfile/tio-sinkhole-jsonl.xml) | VALIDATED | `ENV-2026-05`, confermato `ENV-2026-09` |
| Regole sinkhole | [`rules/tio_sinkhole_rules.xml`](rules/tio_sinkhole_rules.xml) | VALIDATED TP/TN | `ENV-2026-09` |
| EventChannel Windows | [`windows-eventchannel/tio-windows-eventchannels.xml`](windows-eventchannel/tio-windows-eventchannels.xml) | VALIDATED | `ENV-2026-09` |
| FIM Linux appliance | [`linux-fim/tio-appliance-fim.xml`](linux-fim/tio-appliance-fim.xml) | VALIDATED TP/TN | `ENV-2026-09` |
| Audit key mapping | [`lists/tio-audit-keys.txt`](lists/tio-audit-keys.txt) | VALIDATED TP/TN | `ENV-2026-09` |
| Pipeline multi-sorgente | agent → manager → indexer → dashboard | VALIDATED per checkpoint | `ENV-2026-09` |
| Retention manager | alert rotation; `logall/logall_json` off | VALIDATED | `ENV-2026-08` |

## Ambiente validato

- WAZUH-LAB: Ubuntu Server 24.04 LTS, `10.10.10.40/24`, Wazuh 4.14.7 all-in-one;
- SINKHOLE-LAB: Debian 13, `10.10.10.30/24`, Agent `001`;
- WIN11-LAB: Windows 11 Pro, `10.10.10.20/24`, Agent `002`;
- APPLIANCE-LAB: Ubuntu Server 24.04 LTS, `10.10.10.50/24`, Agent `003`;
- `lab-lan` senza forwarding e senza default route sui nodi operativi;
- NTP interno tramite host `10.10.10.1`;
- snapshot `*-TELEMETRY-READY` sui quattro nodi principali.

## Sinkhole JSONL

Il frammento `tio-sinkhole-jsonl.xml` segue `/var/log/tio-sinkhole/requests.jsonl` come JSON strutturato. Le regole pubbliche hanno superato la matrice formale:

| Rule | Condizione | ENV-2026-09 |
|---:|---|---|
| `100101` | heartbeat 200 | TP PASS |
| `100102` | status 404 | TP + TN PASS |
| `100103` | status 405 | TP + TN PASS |

## Windows EventChannel

Il frammento pubblico raccoglie Sysmon, PowerShell Operational e TaskScheduler Operational; `Application`, `Security` e `System` sono acquisiti nella baseline agent.

Mapping verificati:

```text
PowerShell 4104 -> 109910
TaskScheduler 106 -> 67014
Security 4698 -> 60228
TaskScheduler 141 -> 67015
```

Security `4699` è stato osservato localmente durante il cleanup della task, ma non è stato osservato un alert Wazuh corrispondente. Con `logall/logall_json` disabilitati, la persistenza del singolo evento non allertante sul manager non è verificabile.

La rule `109910` è validata nel laboratorio; l'XML manager completo resta privato finché non termina la revisione dedicata del rule pack Windows.

## Finding PowerShell

I comandi diagnostici PowerShell che contengono letteralmente il trigger possono essere registrati a loro volta da Script Block Logging e generare alert `109910`. In `ENV-2026-09` l'evento intenzionale è stato separato dagli artefatti del test harness tramite identificatori dell'evento; il metodo successivo evita il trigger letterale nei comandi diagnostici.

## Audit Linux appliance

La lista CDB include:

```text
tio_appliance_exec:execute
```

L'esecuzione del marker benigno ha prodotto `execve success=yes` e rule `80789`; un'attività benigna fuori dalla watch ha prodotto `80789 = 0`.

## FIM Whodata

Il frammento `linux-fim/tio-appliance-fim.xml` monitora:

```xml
<directories check_all="yes" realtime="yes" whodata="yes" report_changes="yes">/opt/tio-appliance-lab/data</directories>
```

La watch dinamica `wazuh_fim` non deve essere duplicata con una watch Audit personalizzata sullo stesso percorso.

Matrice formale:

| Rule | Evento | Risultato |
|---:|---|---|
| `554` | added | TP PASS |
| `550` | modified | TP PASS, SHA-256 old/new osservati |
| `553` | deleted | cleanup PASS |
| target FIM | file fuori `/opt/tio-appliance-lab/data` | TN PASS |

Whodata ha incluso utente e processo responsabile.

## Retention manager

`ENV-2026-08` mantiene:

```text
logall=no
logall_json=no
```

La rotazione degli alert e la capacità disco sono state verificate. Questa scelta evita una raccolta raw indiscriminata, ma limita l'osservabilità dei TN al criterio `nessun alert target` più l'evidenza locale dell'azione quando necessaria.

## Validazione

Manager:

```bash
/var/ossec/bin/wazuh-analysisd -t
systemctl restart wazuh-manager
```

Agent Linux:

```bash
/var/ossec/bin/wazuh-syscheckd -t
/var/ossec/bin/wazuh-agentd -t
/var/ossec/bin/wazuh-logcollector -t
```

## Limiti

- Le configurazioni pubbliche validano il laboratorio, non costituiscono profili di produzione.
- Marker, 404, 405 e singole modifiche FIM non dimostrano da soli attività malevola.
- Retention e matrice TP/TN sono completate; restano metriche formali, tuning, smoke test coordinato e repeatability dopo rollback.
- `ENV-2026-09` non equivale ancora a `LOGGING-READY`.

Evidenze collegate:

- [`../../evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md)
- [`../../evidence/sanitized/ENV-2026-08-retention-baseline.md`](../../evidence/sanitized/ENV-2026-08-retention-baseline.md)
- [`../../evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md`](../../evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md)
