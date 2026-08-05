# Stato di avanzamento

Aggiornare questo file soltanto quando esiste un'evidenza verificabile. Un checkpoint parziale può portare una fase a `IN PROGRESS`, ma `VALIDATED` richiede il completamento della relativa Definition of Done.

## Riepilogo

| Indicatore | Valore |
|---|---|
| Fase primaria attiva | `STEP-02 — Rete e VM` |
| Attività parallele | `STEP-03 — Baseline telemetria`, `STEP-04 — Smoke test` |
| Ultimo checkpoint | `ENV-2026-06 — telemetria multi-sorgente isolata` |
| Ultimo aggiornamento | `2026-08-05 UTC` |
| Prossima attività | creare `APPLIANCE-LAB` e configurare auditd/FIM |
| Issue topologia | `#3 — Costruire rete host-only e macchine virtuali` |
| Issue smoke test | `#5 — Dataset sintetico, sinkhole e snapshot LOGGING-READY` |

## Avanzamento complessivo

| ID | Fase | Stato | Evidence / PR | Data UTC |
|---|---|---|---|---|
| STEP-00 | Governance e publication gate | IN PROGRESS | storage privato e `.gitignore` verificati | 2026-08-03 |
| STEP-01 | Metodo analitico A/B/C | NOT STARTED | - | - |
| STEP-02 | Rete e VM | IN PROGRESS | `ENV-2026-03`…`ENV-2026-06` | 2026-08-05 |
| STEP-03 | Wazuh, Sysmon, PowerShell e auditd | IN PROGRESS | pipeline Windows + Linux/JSONL validata; appliance mancante | 2026-08-05 |
| STEP-04 | Smoke test e snapshot LOGGING-READY | IN PROGRESS | tre snapshot `*-TELEMETRY-READY`; non è `LOGGING-READY` | 2026-08-05 |
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
| `ENV-2026-05` | STEP-03/04 parziale | Wazuh all-in-one, agent Linux, ingestione JSONL, regole 200/404/405 e snapshot `WAZUH-PIPELINE-READY` | PASS | 2026-08-04 |
| `ENV-2026-06` | STEP-02/03/04 parziale | Windows telemetry, NTP interno, dataset sintetico, smoke test NAT-less e snapshot per nodo | PASS parziale | 2026-08-05 |

## Dettaglio STEP-02

| Componente | Stato | Nota |
|---|---|---|
| KVM/QEMU e libvirt | VALIDATED | accelerazione hardware e gestione VM operative |
| Rete `lab-lan` | VALIDATED | `10.10.10.0/24`, nessun forwarding |
| NTP interno | VALIDATED | host `10.10.10.1`; client `.20`, `.30`, `.40` osservati |
| WIN11-LAB | WIN11-TELEMETRY-READY | `10.10.10.20/24`, NAT rimossa, zero default route |
| SINKHOLE-LAB | SINKHOLE-TELEMETRY-READY | `10.10.10.30/24`, HTTP/JSONL e agent validati |
| WAZUH-LAB | WAZUH-TELEMETRY-READY | `10.10.10.40/24`, pipeline multi-sorgente validata |
| APPLIANCE-LAB | NOT STARTED | indirizzo previsto `10.10.10.50` |
| ANALYST-LAB | OPTIONAL | indirizzo previsto `10.10.10.60` |

## Dettaglio checkpoint ENV-2026-06

### Windows e dataset

| Controllo | Stato |
|---|---|
| Wazuh Agent `WIN11-LAB` / ID 002 Active | PASS |
| Sysmon Operational acquisito | PASS |
| PowerShell Operational e Script Block Logging 4104 | PASS |
| Task Scheduler Operational | PASS |
| auditing Security 4698/4699 | PASS |
| account standard `labuser`, non amministratore | PASS |
| dataset sintetico: 27 file + manifesto | PASS |
| integrità: 27/27, nessun file modificato/mancante/inatteso | PASS |
| test positivo Sysmon FileCreate sotto `C:\Lab\` | PASS |
| test negativo FileCreate fuori dai path monitorati | PASS |
| task headless come SYSTEM e correlazione Sysmon | PASS |
| cleanup di task, marker e directory temporanee | PASS |

### Isolamento e tempo

| Controllo | Stato |
|---|---|
| server NTP interno `10.10.10.1:123/udp` | PASS |
| WIN11-LAB usa `10.10.10.1` | PASS |
| WAZUH-LAB usa `10.10.10.1` | PASS |
| SINKHOLE-LAB usa `10.10.10.1` | PASS |
| NAT-TEMP rimossa da WIN11-LAB | PASS |
| zero default route su WIN11-LAB | PASS |
| Wazuh `10.10.10.40:1514/tcp` raggiungibile | PASS |
| sinkhole `10.10.10.30:8080/tcp` raggiungibile | PASS |

### Smoke test NAT-less

| Prova | Stato |
|---|---|
| Sysmon Event ID 1 / rule 92004 | PASS |
| PowerShell Event ID 4104 / rule 109910 | PASS |
| Task Scheduler Event ID 106 / rule 67014 | PASS |
| Security Event ID 4698 / rule 60228 | PASS |
| Task Scheduler Event ID 141 / rule 67015 | PASS |
| sinkhole `GET /final-natless-check` → 404 / rule 100102 | PASS |
| alert verificati in CLI e Threat Hunting | PASS |

### Snapshot e integrità privata

| Nodo | Snapshot | Stato |
|---|---|---|
| WIN11-LAB | `WIN11-TELEMETRY-READY` | PASS |
| WAZUH-LAB | `WAZUH-TELEMETRY-READY` | PASS |
| SINKHOLE-LAB | `SINKHOLE-TELEMETRY-READY` | PASS |

I pacchetti privati, i manifesti SHA-256 e i metadati XML degli snapshot sono stati verificati prima e dopo il trasferimento. Non sono pubblicati nel repository.

## Evidenze e configurazioni pubbliche

- `evidence/sanitized/ENV-2026-03-sinkhole-baseline.md`;
- `evidence/sanitized/ENV-2026-04-sinkhole-ready.md`;
- `evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`;
- `evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`;
- `configs/sinkhole/`;
- `configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml`;
- `configs/wazuh/windows-eventchannel/tio-windows-eventchannels.xml`;
- `configs/wazuh/rules/tio_sinkhole_rules.xml`.

## Limiti correnti

- `ENV-2026-06` non equivale a `LOGGING-READY`.
- APPLIANCE-LAB, auditd e Wazuh FIM non sono ancora disponibili.
- Retention finale, matrice TP/TN, metriche e ripetizione completa dopo rollback restano da completare.
- La regola Windows `109910` è validata nel laboratorio; la pubblicazione dell'XML manager completo richiede una revisione dedicata.
- Le raw evidence, gli inventari completi, gli UUID, i MAC, le credenziali, gli archivi privati e i percorsi locali restano fuori dal repository.

## Regole di aggiornamento

- `NOT STARTED`: nessuna attività verificabile iniziata.
- `NEXT`: prossimo componente pianificato.
- `IN PROGRESS`: lavoro avviato; possono esistere checkpoint ed evidenze parziali.
- `BLOCKED`: attività non eseguibile finché non viene superato un gate precedente.
- `VALIDATED`: Definition of Done della fase completata con test ripetibili.
- `SANITIZED`: artefatto pubblico revisionato per privacy e sicurezza.
- `PUBLISHED`: caso completo pubblicato con evidenze, hash, fonti e limiti.

Per i casi operativi, `VALIDATED` richiede almeno test positivo, test negativo, rollback o cleanup e verifica della baseline.
