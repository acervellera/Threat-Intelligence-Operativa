# Stato di avanzamento

Aggiornare questo file soltanto quando esiste un'evidenza verificabile. Un checkpoint parziale può portare una fase a `IN PROGRESS`, ma `VALIDATED` richiede il completamento della relativa Definition of Done.

## Riepilogo

| Indicatore | Valore |
|---|---|
| Fase primaria attiva | `STEP-02 — Rete e VM` |
| Attività parallele | `STEP-03 — Baseline telemetria`, `STEP-04 — Smoke test` |
| Ultimo checkpoint | `ENV-2026-05 — pipeline Wazuh ↔ sinkhole isolata` |
| Ultimo aggiornamento | `2026-08-04 UTC` |
| Prossima attività | creare `WIN11-LAB` su `10.10.10.20` |
| Issue topologia | `#3 — Costruire rete host-only e macchine virtuali` |
| Issue smoke test | `#5 — Dataset sintetico, sinkhole e snapshot LOGGING-READY` |

## Avanzamento complessivo

| ID | Fase | Stato | Evidence / PR | Data UTC |
|---|---|---|---|---|
| STEP-00 | Governance e publication gate | IN PROGRESS | storage privato e `.gitignore` verificati | 2026-08-03 |
| STEP-01 | Metodo analitico A/B/C | NOT STARTED | - | - |
| STEP-02 | Rete e VM | IN PROGRESS | `ENV-2026-03`, `ENV-2026-04`, `ENV-2026-05` | 2026-08-04 |
| STEP-03 | Wazuh, Sysmon, PowerShell e auditd | IN PROGRESS | pipeline Linux/JSONL isolata validata | 2026-08-04 |
| STEP-04 | Smoke test e snapshot LOGGING-READY | IN PROGRESS | `evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md` | 2026-08-04 |
| CASE-01 | CaptiveCrunch / Storm-2945 | BLOCKED | attende `LOGGING-READY` | - |
| CASE-02A | ACR Stealer Chain A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-02B | ACR Stealer Chain B | BLOCKED | attende `LOGGING-READY` | - |
| CASE-03 | UNC1069 | BLOCKED | attende `LOGGING-READY` | - |
| CASE-04 | UNC3753 / Luna Moth | BLOCKED | attende `LOGGING-READY` | - |
| CASE-05 | BRICKSTORM | BLOCKED | attende `LOGGING-READY-LINUX` | - |
| CASE-06 | WinRAR CVE-2025-8088 | BLOCKED | attende `LOGGING-READY` | - |
| STEP-11 | Test matrix e metriche | NOT STARTED | - | - |
| STEP-12 | Portfolio finale | NOT STARTED | - | - |

## Checkpoint pubblicati

| Exercise ID | Fase | Artefatto | Esito | Data UTC |
|---|---|---|---|---|
| `ENV-2026-03` | STEP-02 | SINKHOLE-LAB isolata con snapshot `CLEAN-OS` | PASS | 2026-08-03 |
| `ENV-2026-04` | STEP-04 parziale | servizio HTTP, JSONL, logrotate, health check e snapshot `SINKHOLE-READY` | PASS | 2026-08-03 |
| `ENV-2026-05` | STEP-03/04 parziale | Wazuh all-in-one, agent Linux, ingestione JSONL, regole 200/404/405, isolamento e snapshot `WAZUH-PIPELINE-READY` | PASS | 2026-08-04 |

## Dettaglio STEP-02

| Componente | Stato | Nota |
|---|---|---|
| KVM/QEMU e libvirt | VALIDATED | accelerazione hardware e gestione VM operative |
| Rete `lab-lan` | VALIDATED | `10.10.10.0/24`, nessun forwarding |
| SINKHOLE-LAB | SINKHOLE-READY | `10.10.10.30/24`, NAT rimossa, agent Wazuh Active |
| WIN11-LAB | NEXT | indirizzo previsto `10.10.10.20` |
| WAZUH-LAB | WAZUH-PIPELINE-READY | `10.10.10.40/24`, NAT rimossa, pipeline isolata validata |
| APPLIANCE-LAB | NOT STARTED | indirizzo previsto `10.10.10.50` |
| ANALYST-LAB | OPTIONAL | indirizzo previsto `10.10.10.60` |

## Dettaglio checkpoint ENV-2026-05

| Controllo | Stato |
|---|---|
| Ubuntu Server 24.04 LTS su WAZUH-LAB | PASS |
| filesystem root circa 77 GiB | PASS |
| `wazuh-indexer` active/enabled | PASS |
| `wazuh-manager` active/enabled | PASS |
| `filebeat` active/enabled | PASS |
| `wazuh-dashboard` active/enabled | PASS |
| dashboard HTTPS | HTTP 302 |
| cluster indexer | green |
| shard non assegnati | 0 |
| snapshot `CLEAN-OS` e `WAZUH-READY` | PASS |
| agent `sinkhole-lab` | Active |
| connessione agent-manager su `10.10.10.40:1514/tcp` | PASS |
| SINKHOLE-LAB senza NAT e default route | PASS |
| WAZUH-LAB senza NAT e default route | PASS |
| connettività interna host/sinkhole | PASS |
| egress Internet da WAZUH-LAB | DENIED come previsto |
| Logcollector segue `requests.jsonl` | PASS |
| regola `100101` heartbeat 200 | PASS |
| regola `100102` HTTP 404 | PASS |
| regola `100103` HTTP 405 | PASS |
| alert isolati nel manager/indexer/dashboard | PASS |
| snapshot `WAZUH-PIPELINE-READY` | PASS, VM spenta |
| riavvio successivo e servizi/agent | PASS |

## Evidenze e limiti

- Evidenze pubbliche:
  - `evidence/sanitized/ENV-2026-04-sinkhole-ready.md`;
  - `evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`.
- Configurazioni pubbliche:
  - `configs/sinkhole/`;
  - `configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml`;
  - `configs/wazuh/rules/tio_sinkhole_rules.xml`.
- Le evidenze raw, i log completi, gli UUID, i MAC, le credenziali e i percorsi locali restano privati.
- Lo snapshot `WAZUH-PIPELINE-READY` contiene la configurazione corrente isolata della pipeline Linux/JSONL.
- L'NTP esterno non è raggiungibile senza egress; resta da predisporre una sorgente temporale interna.
- `ENV-2026-05` non equivale a `LOGGING-READY`: mancano WIN11-LAB, Sysmon, PowerShell, auditing Windows, APPLIANCE-LAB, dataset sintetico, test negativi formali e ripetizione dopo rollback.

## Regole di aggiornamento

- `NOT STARTED`: nessuna attività verificabile iniziata.
- `NEXT`: prossimo componente pianificato.
- `IN PROGRESS`: lavoro avviato; possono esistere checkpoint ed evidenze parziali.
- `BLOCKED`: attività non eseguibile finché non viene superato un gate precedente.
- `VALIDATED`: Definition of Done della fase completata con test ripetibili.
- `SANITIZED`: artefatto pubblico revisionato per privacy e sicurezza.
- `PUBLISHED`: caso completo pubblicato con evidenze, hash, fonti e limiti.

Per i casi operativi, `VALIDATED` richiede almeno test positivo, test negativo, rollback o cleanup e verifica della baseline.
