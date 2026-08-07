# Stato di avanzamento

Aggiornare questo file soltanto quando esiste un'evidenza verificabile. Un checkpoint parziale può portare una fase a `IN PROGRESS`, ma `VALIDATED` richiede il completamento della relativa Definition of Done.

## Riepilogo

| Indicatore | Valore |
|---|---|
| Fase primaria attiva | `STEP-02 — Rete e VM` |
| Attività parallele | `STEP-03 — Baseline telemetria`, `STEP-04 — Detection engineering` |
| Ultimo checkpoint | `ENV-2026-11 — rollback coordinato e ripetibilità` |
| Ultimo aggiornamento | `2026-08-07 UTC` |
| Retention finale | `PASS` (`ENV-2026-08`) |
| Matrice TP/TN | `14/14 PASS` (`ENV-2026-09`) |
| Metriche | `PASS` (`ENV-2026-10`) |
| Repeatability rappresentativa | `8/8 PASS dopo rollback` (`ENV-2026-11`) |
| Prossima attività | cleanup/baseline globali, inventario snapshot finale e snapshot globali |
| Track A | quattro nodi `TELEMETRY-READY`; gate globale ancora aperto |
| Track B | `PLANNED / BLOCKED`; dopo `LOGGING-READY` e primo caso benigno completo |

## Avanzamento complessivo

| ID | Fase | Stato | Evidence / PR | Data UTC |
|---|---|---|---|---|
| STEP-00 | Governance e publication gate | IN PROGRESS | storage privato e `.gitignore` verificati | 2026-08-03 |
| STEP-01 | Metodo analitico A/B/C | NOT STARTED | - | - |
| STEP-02 | Rete e VM | IN PROGRESS | `ENV-2026-03`…`ENV-2026-11`; rollback coordinato verificato | 2026-08-07 |
| STEP-03 | Wazuh, Sysmon, PowerShell e auditd | IN PROGRESS | baseline multi-sorgente + retention + rollback | 2026-08-07 |
| STEP-04 | Smoke test / detection / snapshot LOGGING-READY | IN PROGRESS | TP/TN, metriche e repeatability PASS; snapshot finali mancanti | 2026-08-07 |
| CASE-01 | CaptiveCrunch / Storm-2945 — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-02A | ACR Stealer Chain A — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-02B | ACR Stealer Chain B — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-03 | UNC1069 — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-04 | UNC3753 / Luna Moth — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-05 | BRICKSTORM — Track A | BLOCKED | attende `LOGGING-READY-LINUX` | - |
| CASE-06 | WinRAR CVE-2025-8088 — Track A | BLOCKED | attende `LOGGING-READY` | - |
| TRACK-B | Malware analysis separata | PLANNED / BLOCKED | attende `LOGGING-READY` e primo caso Track A completo | 2026-08-06 |
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

## Stato delle sorgenti

| Sorgente | Stato |
|---|---|
| Sinkhole JSONL 200/404/405 | VALIDATED |
| Wazuh manager/indexer/dashboard | VALIDATED per checkpoint |
| WIN11 EventChannel | VALIDATED |
| Sysmon | VALIDATED per baseline LAB |
| PowerShell 4104 / rule `109910` | VALIDATED |
| Task Scheduler 106/141 | VALIDATED |
| Security 4698 | VALIDATED con alert Wazuh |
| Security 4699 | osservato localmente; alert Wazuh non osservato |
| auditd `tio_appliance_exec` / `80789` | VALIDATED |
| FIM Whodata `554/550/553` | VALIDATED |
| retention multi-nodo | VALIDATED |
| rollback coordinato | VALIDATED sul checkpoint `ENV-2026-11` |

## ENV-2026-09 — risultato formale TP/TN

| Area | TP | TN | Esito |
|---|---:|---:|---|
| Windows | 2 | 2 | 4/4 PASS |
| Sinkhole | 3 | 2 | 5/5 PASS |
| Audit Linux | 1 | 1 | 2/2 PASS |
| FIM Linux | 2 | 1 | 3/3 PASS |
| **Totale** | **8** | **6** | **14/14 PASS** |

Finding principali:

- i comandi diagnostici PowerShell possono auto-generare Event ID 4104 e contaminare il test se contengono letteralmente il trigger; gli alert del test harness sono stati separati dall'evento intenzionale e il metodo è stato corretto;
- la cancellazione Scheduled Task produce localmente Security `4699`, ma non è stato osservato un alert Wazuh corrispondente;
- con `logall/logall_json` disabilitati, l'assenza di alert target è dimostrabile, mentre la persistenza manager del singolo evento non allertante non è osservabile;
- FIM Whodata ha fornito utente/processo e SHA-256 old/new sulle modifiche;
- il cleanup FIM ha prodotto `deleted -> 553`.

## ENV-2026-10 — metriche

| Metrica | Risultato |
|---|---:|
| Completamento scenari | 14/14 — 100,00% |
| Efficacia True Positive | 8/8 — 100,00% |
| Selettività True Negative | 6/6 — 100,00% |
| Precisione grezza alert | 76,92% |
| Precisione classificata sul set controllato | 100,00% |
| Latenza mediana osservabile | 1,034 s |
| Completezza campi | 68/68 — 100,00% |

La precisione grezza conserva tre artefatti noti del test harness. Otto dei dieci alert intenzionali dispongono di timestamp sorgente/alert correlabili per la metrica di latenza; i due FIM restano `NON_MISURABILE` per questa specifica metrica.

## ENV-2026-11 — rollback e repeatability

| Controllo | Esito |
|---|---:|
| Baseline coordinata creata a VM spente | PASS |
| VM ripristinate | 4/4 |
| Artefatti RUN-1 assenti dopo revert | 3/3 |
| Alert RUN-1 sul manager ripristinato | 0 |
| RUN-1 | 8/8 PASS |
| RUN-2 valido | 8/8 PASS |
| Repeatability sul set rappresentativo | 100,00% |

Due tentativi Windows non validi sono stati conservati come finding del test harness: doppia esecuzione sorgente e marker vuoti. Non sono stati riclassificati come fallimenti della detection.

## Snapshot e integrità privata

| Nodo | Snapshot storico validato | Baseline coordinata ENV-2026-11 |
|---|---|---|
| WIN11-LAB | `WIN11-TELEMETRY-READY` | PASS |
| WAZUH-LAB | `WAZUH-TELEMETRY-READY` | PASS |
| SINKHOLE-LAB | `SINKHOLE-TELEMETRY-READY` | PASS |
| APPLIANCE-LAB | `APPLIANCE-TELEMETRY-READY` | PASS |

Le evidenze private di `ENV-2026-09`, `ENV-2026-10`, `ENV-2026-11` e delle visualizzazioni sono state congelate con manifesti SHA-256 verificati. Hash privati, percorsi host e raw evidence non sono pubblicati.

## Evidenze pubbliche principali

- `evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`;
- `evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md`;
- `evidence/sanitized/ENV-2026-08-retention-baseline.md`;
- `evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md`;
- `evidence/sanitized/ENV-2026-10-detection-metrics.md`;
- `evidence/sanitized/ENV-2026-11-rollback-repeatability.md`;
- `configs/sinkhole/`;
- `configs/auditd/70-tio-appliance.rules`;
- `configs/wazuh/`;
- `scripts/lab/tio-marker.sh`;
- `docs/07-malware-analysis-track/README.md`.

## Cosa manca per LOGGING-READY

- verifica globale cleanup e baseline;
- consolidamento finale dell'inventario snapshot;
- snapshot coordinati `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Ordine operativo approvato

1. completare cleanup/baseline globali e inventario snapshot;
2. creare `LOGGING-READY` e `LOGGING-READY-LINUX`;
3. completare il primo caso benigno end-to-end;
4. costruire una sola volta la Track B separata e sacrificabile;
5. ripetere il primo caso con analisi statica e dinamica solo se appropriata;
6. confrontare fonti, emulazione e comportamento osservato;
7. aggiornare detection, gap, tuning e report;
8. applicare il ciclo a due track ai casi successivi.

## Regole di aggiornamento

- `NOT STARTED`: nessuna attività verificabile iniziata.
- `NEXT`: prossimo componente pianificato.
- `PLANNED / BLOCKED`: attività definita ma non eseguibile finché i gate precedenti non sono soddisfatti.
- `IN PROGRESS`: lavoro avviato; possono esistere checkpoint ed evidenze parziali.
- `BLOCKED`: attività non eseguibile finché non viene superato un gate precedente.
- `VALIDATED`: Definition of Done completata con test ripetibili.
- `SANITIZED`: artefatto pubblico revisionato per privacy e sicurezza.
- `PUBLISHED`: caso completo pubblicato con evidenze, hash, fonti e limiti.
