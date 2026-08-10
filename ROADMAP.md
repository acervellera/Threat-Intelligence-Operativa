# Roadmap operativa

La roadmap segue una dipendenza rigida: una fase si chiude solo quando la relativa Definition of Done è soddisfatta. I checkpoint parziali possono essere pubblicati come evidenze `SANITIZED`, ma non trasformano automaticamente l'intera fase in `VALIDATED`.

Il progetto è diviso in due percorsi:

- **Track A:** emulazione benigna, telemetria, detection engineering, cleanup e reporting;
- **Track B:** analisi statica e dinamica controllata di campioni reali in una sandbox distinta e sacrificabile.

La Track B viene costruita soltanto dopo `LOGGING-READY` e dopo il completamento end-to-end del primo caso benigno nella Track A.

## Stato sintetico

| Fase | Stato | Evidenza principale | Prossima azione |
|---|---|---|---|
| Fase 0 — Governance | IN PROGRESS | storage privato e policy di sanificazione | publication checklist CASE-01 |
| Fase 1 — Metodo analitico | NEXT | da applicare a CASE-01 | fonti + confidence A/B/C |
| Fase 2 — Topologia e rete Track A | VALIDATED | `ENV-2026-03`…`ENV-2026-13` | usare baseline finale |
| Fase 3 — Raccolta e baseline Track A | VALIDATED | retention, rollback, cleanup, snapshot finali | supportare CASE-01 |
| Fase 4 — Detection engineering Track A | VALIDATED per gate infrastrutturale | TP/TN + metriche + repeatability | detection del primo caso |
| Primo caso Track A | READY / NEXT | issue #6 | threat-intelligence brief e piano benigno |
| Track B — Malware analysis | PLANNED / BLOCKED | metodologia pubblica definita | attendere CASE-01 completo |
| Casi successivi a due track | BLOCKED | - | attendere validazione Track B |

## Checkpoint verificati

- `ENV-2026-03` — baseline isolata SINKHOLE-LAB;
- `ENV-2026-04` — sinkhole HTTP/JSONL e `SINKHOLE-READY`;
- `ENV-2026-05` — pipeline Wazuh ↔ sinkhole isolata;
- `ENV-2026-06` — telemetria Windows + sinkhole + Wazuh;
- `ENV-2026-07` — APPLIANCE-LAB auditd/FIM Whodata;
- `ENV-2026-08` — retention finale multi-nodo, PASS;
- `ENV-2026-09` — matrice formale 8 TP + 6 TN, 14/14 PASS;
- `ENV-2026-10` — metriche di detection e qualità dei dati, PASS;
- `ENV-2026-11` — rollback coordinato e repeatability rappresentativa 8/8, PASS;
- `ENV-2026-12` — cleanup globale e health check finale, PASS;
- `ENV-2026-13` — inventario snapshot finale e `LOGGING-READY`, PASS.

## Fase 0 — Governance del repository

- [x] Leggere `SECURITY.md`.
- [x] Definire storage privato per raw evidence.
- [x] Adottare classificazione `PUBLIC`, `SANITIZED`, `PRIVATE`.
- [ ] Compilare e archiviare la checklist di pubblicazione del primo caso.
- [x] Definire che campioni e materiale contaminato non entrano nel repository pubblico.

## Fase 1 — Metodo analitico

Da applicare ora a CASE-01:

- [ ] compilare Contesto, Catena, ATT&CK, Emulazione, Detection e Response;
- [ ] applicare confidence A/B/C;
- [ ] definire test positivo, test negativo, kill switch e cleanup;
- [ ] assegnare Case ID e usare UTC;
- [ ] distinguere comportamento documentato, emulato e osservato.

## Fase 2 — Topologia e rete Track A

### Completato

- [x] KVM/QEMU con libvirt;
- [x] rete host-only `10.10.10.0/24` senza forwarding;
- [x] WIN11-LAB, SINKHOLE-LAB, WAZUH-LAB e APPLIANCE-LAB;
- [x] NAT rimossa dai quattro nodi principali;
- [x] assenza di default route;
- [x] NTP interno `10.10.10.1`;
- [x] snapshot `*-TELEMETRY-READY`;
- [x] baseline coordinata `ENV-2026-11-BASELINE`;
- [x] health check e connettività dopo rollback;
- [x] cleanup globale;
- [x] inventario snapshot finale;
- [x] `LOGGING-READY` e `LOGGING-READY-LINUX`.

**Stato:** `VALIDATED`.

## Fase 3 — Raccolta e baseline Track A

### Completato

- [x] Sinkhole HTTP/JSONL;
- [x] Wazuh all-in-one e agent Linux/Windows;
- [x] Sysmon, PowerShell 4104, Task Scheduler, Security 4698/4699;
- [x] dataset sintetico e manifesto;
- [x] auditd su APPLIANCE-LAB;
- [x] Wazuh FIM realtime Whodata;
- [x] retention finale multi-nodo (`ENV-2026-08`);
- [x] test positivi e negativi formali (`ENV-2026-09`);
- [x] rollback coordinato (`ENV-2026-11`);
- [x] repeatability 8/8 sul set rappresentativo (`ENV-2026-11`);
- [x] cleanup globale e health check (`ENV-2026-12`);
- [x] snapshot finali (`ENV-2026-13`).

**Stato:** `VALIDATED`.

## Fase 4 — Detection engineering Track A

### Gate infrastrutturale completato

- [x] regole sinkhole `100100`–`100103`;
- [x] marker PowerShell `109910`;
- [x] Audit execute `80789` con `tio_appliance_exec`;
- [x] FIM `550`, `553`, `554` Whodata;
- [x] matrice formale multi-nodo: 8 TP + 6 TN, 14/14 PASS;
- [x] cleanup FIM `deleted -> 553`;
- [x] finding test-harness PowerShell documentato;
- [x] metriche di scenario, precisione, latenza osservabile e data quality (`ENV-2026-10`);
- [x] repeatability dopo rollback (`ENV-2026-11`);
- [x] baseline finale `LOGGING-READY` (`ENV-2026-13`).

### Lavoro futuro legato ai casi

- [ ] detection e tuning specifici di CASE-01;
- [ ] pubblicare rule pack Windows dopo revisione dedicata;
- [ ] tuning per frequenza e contesto derivato dai casi.

## Gate globale Track A — LOGGING-READY

- [x] retention finale;
- [x] matrice TP/TN multi-nodo;
- [x] metriche di scenario, precisione, latenza osservabile e data quality;
- [x] smoke test coordinato rappresentativo dei quattro nodi;
- [x] rollback completo delle quattro VM e repeatability sul set rappresentativo;
- [x] cleanup e controllo baseline globali;
- [x] inventario snapshot finale;
- [x] snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

**Gate:** `PASS`.

## Primo caso Track A — CASE-01

**Stato:** `READY / NEXT`  
**Caso:** CaptiveCrunch / Storm-2945  
**Issue:** #6

Sequenza:

1. [ ] raccogliere e verificare le fonti primarie/affidabili;
2. [ ] compilare threat-intelligence brief;
3. [ ] distinguere fatti documentati, inferenze e ipotesi;
4. [ ] assegnare confidence A/B/C;
5. [ ] costruire mapping MITRE ATT&CK;
6. [ ] definire emulazione esclusivamente benigna e limiti;
7. [ ] definire telemetria attesa e detection;
8. [ ] eseguire TP/TN;
9. [ ] produrre timeline UTC ed evidenze E-001…E-006;
10. [ ] eseguire cleanup;
11. [ ] rollback alla baseline finale e ripetizione;
12. [ ] produrre finding, incident response e pubblicazione sanificata.

Limiti già stabiliti per CASE-01: nessun device code reale, cookie theft, UAC bypass o AMSI tampering.

## Track B — Malware analysis separata

**Stato:** `PLANNED / BLOCKED`  
**Metodo:** `docs/07-malware-analysis-track/README.md`

Gate di ingresso rimanente:

- [x] Track A a `LOGGING-READY`;
- [ ] primo caso benigno completato end-to-end;
- [ ] storage privato per campioni ed evidenze contaminate;
- [ ] checklist di rischio, kill switch e destruction record;
- [ ] rete distinta senza routing verso Track A o rete reale;
- [ ] manager Wazuh e sinkhole separati;
- [ ] immagini golden e overlay sacrificabili;
- [ ] condivisioni host, clipboard e drag-and-drop disabilitati.

La dinamica Track B non è obbligatoria per tutti i casi. Campioni ad alto rischio possono essere limitati alla sola analisi statica o richiedere un host fisico dedicato.

## Sequenza operativa immediata

1. avviare CASE-01 dalla baseline `LOGGING-READY`;
2. completare fonti, confidence A/B/C e mapping ATT&CK;
3. progettare ed eseguire l'emulazione benigna;
4. completare detection, TP/TN, evidenze, cleanup e rollback;
5. pubblicare CASE-01 sanificato;
6. solo allora costruire la Track B separata;
7. confrontare comportamento documentato, emulato e osservato.
