# Stato di avanzamento

Aggiornare questo file soltanto quando esiste un'evidenza verificabile. Un checkpoint parziale può portare una fase a `IN PROGRESS`, ma `VALIDATED` richiede il completamento della relativa Definition of Done.

## Riepilogo

| Indicatore | Valore |
|---|---|
| Fase primaria attiva | `CASE-01 — CaptiveCrunch / Storm-2945` |
| Gate infrastrutturale Track A | `LOGGING-READY — PASS` |
| Ultimo checkpoint | `ENV-2026-13 — snapshot finali LOGGING-READY` |
| Ultimo aggiornamento | `2026-08-10 UTC` |
| Retention finale | `PASS` (`ENV-2026-08`) |
| Matrice TP/TN | `14/14 PASS` (`ENV-2026-09`) |
| Metriche | `PASS` (`ENV-2026-10`) |
| Repeatability rappresentativa | `8/8 PASS dopo rollback` (`ENV-2026-11`) |
| Cleanup globale | `PASS` (`ENV-2026-12`) |
| Snapshot finali | `PASS` (`ENV-2026-13`) |
| CASE-01 | `READY / NEXT` |
| Track B | `PLANNED / BLOCKED`; dopo il primo caso Track A completo |

## Avanzamento complessivo

| ID | Fase | Stato | Evidence / PR | Data UTC |
|---|---|---|---|---|
| STEP-00 | Governance e publication gate | IN PROGRESS | storage privato, `.gitignore` e policy di sanificazione verificati | 2026-08-10 |
| STEP-01 | Metodo analitico A/B/C | NEXT | da applicare a CASE-01 | 2026-08-10 |
| STEP-02 | Rete e VM | VALIDATED | `ENV-2026-03`…`ENV-2026-13`; rollback e snapshot finali | 2026-08-10 |
| STEP-03 | Wazuh, Sysmon, PowerShell e auditd | VALIDATED | baseline multi-sorgente, retention, cleanup e snapshot finali | 2026-08-10 |
| STEP-04 | Smoke test / detection / snapshot LOGGING-READY | VALIDATED | TP/TN, metriche, repeatability, cleanup e `LOGGING-READY` | 2026-08-10 |
| CASE-01 | CaptiveCrunch / Storm-2945 — Track A | NEXT | issue #6; baseline `LOGGING-READY` disponibile | 2026-08-10 |
| CASE-02A | ACR Stealer Chain A — Track A | BLOCKED | attende CASE-01 | - |
| CASE-02B | ACR Stealer Chain B — Track A | BLOCKED | attende CASE-01 | - |
| CASE-03 | UNC1069 — Track A | BLOCKED | attende CASE-01 | - |
| CASE-04 | UNC3753 / Luna Moth — Track A | BLOCKED | attende CASE-01 | - |
| CASE-05 | BRICKSTORM — Track A | BLOCKED | attende CASE-01 e baseline Linux finale disponibile | - |
| CASE-06 | WinRAR CVE-2025-8088 — Track A | BLOCKED | attende CASE-01 | - |
| TRACK-B | Malware analysis separata | PLANNED / BLOCKED | attende primo caso Track A completo | 2026-08-10 |
| STEP-11 | Test matrix e metriche | VALIDATED | `ENV-2026-09`, `ENV-2026-10`, `ENV-2026-11` | 2026-08-07 |
| STEP-12 | Portfolio finale | NOT STARTED | - | - |

## Checkpoint pubblicati

| Exercise ID | Fase | Artefatto | Esito | Data UTC |
|---|---|---|---|---|
| `ENV-2026-03` | STEP-02 | SINKHOLE-LAB isolata con snapshot `CLEAN-OS` | PASS | 2026-08-03 |
| `ENV-2026-04` | STEP-04 parziale | HTTP, JSONL, logrotate, health check e `SINKHOLE-READY` | PASS | 2026-08-03 |
| `ENV-2026-05` | STEP-03/04 parziale | Wazuh all-in-one, JSONL e `WAZUH-PIPELINE-READY` | PASS | 2026-08-04 |
| `ENV-2026-06` | STEP-02/03/04 parziale | Windows telemetry, NTP, dataset e smoke test NAT-less | PASS parziale | 2026-08-05 |
| `ENV-2026-07` | STEP-02/03/04 parziale | auditd, FIM Whodata, test isolato e snapshot appliance | PASS parziale | 2026-08-06 |
| `ENV-2026-08` | STEP-03/04 | retention finale multi-nodo | PASS | 2026-08-07 |
| `ENV-2026-09` | STEP-04 | matrice formale 8 TP + 6 TN | PASS | 2026-08-07 |
| `ENV-2026-10` | STEP-11 | metriche di detection e qualità dei dati | PASS | 2026-08-07 |
| `ENV-2026-11` | STEP-02/04/11 | rollback coordinato e repeatability rappresentativa | PASS | 2026-08-07 |
| `ENV-2026-12` | STEP-02/03/04 | cleanup globale e health check finale | PASS | 2026-08-10 |
| `ENV-2026-13` | STEP-02/03/04 | snapshot finali e gate `LOGGING-READY` | PASS | 2026-08-10 |

## Stato delle sorgenti

| Sorgente | Stato |
|---|---|
| Sinkhole JSONL 200/404/405 | VALIDATED |
| Wazuh manager/indexer/dashboard | VALIDATED |
| WIN11 EventChannel | VALIDATED |
| Sysmon | VALIDATED per baseline LAB |
| PowerShell 4104 / rule `109910` | VALIDATED |
| Task Scheduler 106/141 | VALIDATED |
| Security 4698 | VALIDATED con alert Wazuh |
| Security 4699 | osservato localmente; alert Wazuh non osservato |
| auditd `tio_appliance_exec` / `80789` | VALIDATED |
| FIM Whodata `554/550/553` | VALIDATED |
| retention multi-nodo | VALIDATED |
| rollback coordinato | VALIDATED |
| cleanup globale | VALIDATED |
| baseline finale `LOGGING-READY` | VALIDATED |

## Risultati quantitativi

| Metrica | Risultato |
|---|---:|
| Matrice formale TP/TN | 14/14 PASS |
| Efficacia True Positive | 8/8 — 100,00% |
| Selettività True Negative | 6/6 — 100,00% |
| Precisione grezza alert | 76,92% |
| Precisione classificata sul set controllato | 100,00% |
| Latenza mediana osservabile | 1,034 s |
| Completezza campi | 68/68 — 100,00% |
| Repeatability rappresentativa | 8/8 — 100,00% |

I valori percentuali descrivono esclusivamente il set controllato del laboratorio e non rappresentano copertura ATT&CK o prestazioni universali di produzione.

## Snapshot finali

| Nodo | Baseline finale | Stato |
|---|---|---|
| WIN11-LAB | `LOGGING-READY` | PASS |
| WAZUH-LAB | `LOGGING-READY-LINUX` | PASS |
| SINKHOLE-LAB | `LOGGING-READY-LINUX` | PASS |
| APPLIANCE-LAB | `LOGGING-READY-LINUX` | PASS |

Le baseline finali sono state create a VM spente dopo cleanup e health check. Gli inventari e i riepiloghi privati sono stati congelati con manifesti SHA-256 verificati.

## Gate globale Track A — LOGGING-READY

- [x] retention finale;
- [x] matrice TP/TN multi-nodo;
- [x] metriche di scenario, precisione, latenza osservabile e data quality;
- [x] smoke test coordinato rappresentativo dei quattro nodi;
- [x] rollback completo delle quattro VM e repeatability sul set rappresentativo;
- [x] cleanup e controllo baseline globali;
- [x] inventario snapshot finale;
- [x] snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

**Esito gate:** `PASS`.

## Prossima attività — CASE-01

`CASE-01 — CaptiveCrunch / Storm-2945` è ora `READY / NEXT`.

Ordine:

1. raccolta e verifica delle fonti;
2. distinzione fatti documentati / inferenze / ipotesi;
3. confidence A/B/C;
4. mapping MITRE ATT&CK;
5. definizione dell'emulazione benigna e dei limiti;
6. telemetria attesa e detection;
7. TP/TN, evidence register e timeline;
8. cleanup, rollback, repeatability e pubblicazione sanificata.

## Regole di aggiornamento

- `NOT STARTED`: nessuna attività verificabile iniziata.
- `NEXT`: prossimo componente pianificato e sbloccato.
- `PLANNED / BLOCKED`: attività definita ma non eseguibile finché i gate precedenti non sono soddisfatti.
- `IN PROGRESS`: lavoro avviato; possono esistere checkpoint ed evidenze parziali.
- `BLOCKED`: attività non eseguibile finché non viene superato un gate precedente.
- `VALIDATED`: Definition of Done completata con test ripetibili.
- `SANITIZED`: artefatto pubblico revisionato per privacy e sicurezza.
- `PUBLISHED`: caso completo pubblicato con evidenze, hash, fonti e limiti.
