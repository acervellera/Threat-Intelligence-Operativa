# Stato di avanzamento

Aggiornare questo file soltanto quando esiste un'evidenza verificabile. Un checkpoint parziale può portare una fase a `IN PROGRESS`, ma `VALIDATED` richiede il completamento della relativa Definition of Done.

## Riepilogo

| Indicatore | Valore |
|---|---|
| Fase attiva | `STEP-02 — Rete e VM` |
| Ultimo checkpoint | `ENV-2026-03 — Baseline isolata SINKHOLE-LAB` |
| Ultimo aggiornamento | `2026-08-03 UTC` |
| Prossima attività | servizio sinkhole HTTP `10.10.10.30:8080` |
| Issue operativa | `#3` |

## Avanzamento complessivo

| ID | Fase | Stato | Evidence / PR | Data UTC |
|---|---|---|---|---|
| STEP-00 | Governance e publication gate | IN PROGRESS | storage privato e `.gitignore` verificati | 2026-08-03 |
| STEP-01 | Metodo analitico A/B/C | NOT STARTED | - | - |
| STEP-02 | Rete e VM | IN PROGRESS | `evidence/sanitized/ENV-2026-03-sinkhole-baseline.md` | 2026-08-03 |
| STEP-03 | Wazuh, Sysmon, PowerShell e auditd | NOT STARTED | - | - |
| STEP-04 | Smoke test e snapshot LOGGING-READY | NOT STARTED | - | - |
| CASE-01 | CaptiveCrunch / Storm-2945 | NOT STARTED | - | - |
| CASE-02A | ACR Stealer Chain A | NOT STARTED | - | - |
| CASE-02B | ACR Stealer Chain B | NOT STARTED | - | - |
| CASE-03 | UNC1069 | NOT STARTED | - | - |
| CASE-04 | UNC3753 / Luna Moth | NOT STARTED | - | - |
| CASE-05 | BRICKSTORM | NOT STARTED | - | - |
| CASE-06 | WinRAR CVE-2025-8088 | NOT STARTED | - | - |
| STEP-11 | Test matrix e metriche | NOT STARTED | - | - |
| STEP-12 | Portfolio finale | NOT STARTED | - | - |

## Checkpoint pubblicati

| Exercise ID | Fase | Artefatto | Esito | Data UTC |
|---|---|---|---|---|
| `ENV-2026-03` | STEP-02 | `SINKHOLE-LAB` isolata con snapshot `CLEAN-OS` | PASS | 2026-08-03 |

## Dettaglio STEP-02

| Componente | Stato | Nota |
|---|---|---|
| KVM/QEMU e libvirt | VALIDATED | accelerazione hardware e gestione VM operative |
| Rete `lab-lan` | VALIDATED | `10.10.10.0/24`, nessun forwarding |
| SINKHOLE-LAB | CLEAN-OS READY | `10.10.10.30/24`, NAT rimosso, SSH attivo |
| WIN11-LAB | NOT STARTED | indirizzo previsto `10.10.10.20` |
| WAZUH-LAB | NOT STARTED | indirizzo previsto `10.10.10.40` |
| APPLIANCE-LAB | NOT STARTED | indirizzo previsto `10.10.10.50` |
| ANALYST-LAB | OPTIONAL | indirizzo previsto `10.10.10.60` |

## Regole di aggiornamento

- `NOT STARTED`: nessuna attività verificabile iniziata.
- `IN PROGRESS`: lavoro avviato; possono esistere checkpoint ed evidenze parziali.
- `VALIDATED`: Definition of Done della fase completata con test ripetibili.
- `SANITIZED`: artefatto pubblico revisionato per privacy e sicurezza.
- `PUBLISHED`: caso completo pubblicato con evidenze, hash, fonti e limiti.

Per i casi operativi, `VALIDATED` richiede almeno test positivo, test negativo, rollback o cleanup e verifica della baseline.
