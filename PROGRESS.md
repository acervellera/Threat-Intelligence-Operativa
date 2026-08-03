# Stato di avanzamento

Aggiornare questo file soltanto quando esiste un'evidenza verificabile. Un checkpoint parziale può portare una fase a `IN PROGRESS`, ma `VALIDATED` richiede il completamento della relativa Definition of Done.

## Riepilogo

| Indicatore | Valore |
|---|---|
| Fase primaria attiva | `STEP-02 — Rete e VM` |
| Attività parallela | `STEP-04 — componente sinkhole` |
| Ultimo checkpoint | `ENV-2026-04 — SINKHOLE-READY` |
| Ultimo aggiornamento | `2026-08-03 UTC` |
| Prossima attività | creare `WAZUH-LAB` su `10.10.10.40` |
| Issue topologia | `#3 — Costruire rete host-only e macchine virtuali` |
| Issue smoke test | `#5 — Dataset sintetico, sinkhole e snapshot LOGGING-READY` |

## Avanzamento complessivo

| ID | Fase | Stato | Evidence / PR | Data UTC |
|---|---|---|---|---|
| STEP-00 | Governance e publication gate | IN PROGRESS | storage privato e `.gitignore` verificati | 2026-08-03 |
| STEP-01 | Metodo analitico A/B/C | NOT STARTED | - | - |
| STEP-02 | Rete e VM | IN PROGRESS | `ENV-2026-03`, `ENV-2026-04` | 2026-08-03 |
| STEP-03 | Wazuh, Sysmon, PowerShell e auditd | NOT STARTED | - | - |
| STEP-04 | Smoke test e snapshot LOGGING-READY | IN PROGRESS | `evidence/sanitized/ENV-2026-04-sinkhole-ready.md` | 2026-08-03 |
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
| `ENV-2026-03` | STEP-02 | `SINKHOLE-LAB` isolata con snapshot `CLEAN-OS` | PASS | 2026-08-03 |
| `ENV-2026-04` | STEP-04 parziale | servizio HTTP, JSONL, logrotate, health check e snapshot `SINKHOLE-READY` | PASS | 2026-08-03 |

## Dettaglio STEP-02

| Componente | Stato | Nota |
|---|---|---|
| KVM/QEMU e libvirt | VALIDATED | accelerazione hardware e gestione VM operative |
| Rete `lab-lan` | VALIDATED | `10.10.10.0/24`, nessun forwarding |
| SINKHOLE-LAB | SINKHOLE-READY | `10.10.10.30/24`, NAT rimosso, servizio validato |
| WIN11-LAB | NOT STARTED | indirizzo previsto `10.10.10.20` |
| WAZUH-LAB | NEXT | indirizzo previsto `10.10.10.40` |
| APPLIANCE-LAB | NOT STARTED | indirizzo previsto `10.10.10.50` |
| ANALYST-LAB | OPTIONAL | indirizzo previsto `10.10.10.60` |

## Dettaglio checkpoint ENV-2026-04

| Controllo | Stato |
|---|---|
| `tio-sinkhole.service` attivo | PASS |
| avvio automatico abilitato | PASS |
| listener `10.10.10.30:8080` | PASS |
| assenza listener `0.0.0.0:8080` | PASS |
| `GET /heartbeat` | HTTP 200 |
| `HEAD /heartbeat` | HTTP 200 |
| percorso inesistente | HTTP 404 |
| POST rifiutato | HTTP 405 |
| processo non-root | PASS |
| JSONL valido | PASS |
| richiesta host `10.10.10.1` registrata | PASS |
| default route assente | PASS |
| `logrotate.timer` attivo e abilitato | PASS |
| health check automatico | 16 PASS / 0 FAIL |
| snapshot `SINKHOLE-READY` | PASS, interno, VM spenta |

## Evidenze e limiti

- Evidenza pubblica: `evidence/sanitized/ENV-2026-04-sinkhole-ready.md`.
- Configurazioni pubbliche: `configs/sinkhole/` e `scripts/common/tio-sinkhole-check.sh`.
- Le evidenze raw, i log completi, gli UUID, i MAC e i percorsi locali restano privati.
- La prima acquisizione privata aggregata contiene due sezioni mancanti perché `sudo` richiedeva un terminale SSH interattivo; il health check completo e i log sono stati verificati separatamente prima dello snapshot.
- `SINKHOLE-READY` non equivale a `LOGGING-READY`: mancano Wazuh, agent, dashboard, dataset sintetico e smoke test end-to-end.

## Regole di aggiornamento

- `NOT STARTED`: nessuna attività verificabile iniziata.
- `NEXT`: prossimo componente pianificato.
- `IN PROGRESS`: lavoro avviato; possono esistere checkpoint ed evidenze parziali.
- `BLOCKED`: attività non eseguibile finché non viene superato un gate precedente.
- `VALIDATED`: Definition of Done della fase completata con test ripetibili.
- `SANITIZED`: artefatto pubblico revisionato per privacy e sicurezza.
- `PUBLISHED`: caso completo pubblicato con evidenze, hash, fonti e limiti.

Per i casi operativi, `VALIDATED` richiede almeno test positivo, test negativo, rollback o cleanup e verifica della baseline.
