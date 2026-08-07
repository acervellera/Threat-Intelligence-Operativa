# Roadmap operativa

La roadmap segue una dipendenza rigida: una fase si chiude solo quando la relativa Definition of Done è soddisfatta. I checkpoint parziali possono essere pubblicati come evidenze `SANITIZED`, ma non trasformano automaticamente l'intera fase in `VALIDATED`.

Il progetto è diviso in due percorsi:

- **Track A:** emulazione benigna, telemetria, detection engineering, cleanup e reporting;
- **Track B:** analisi statica e dinamica controllata di campioni reali in una sandbox distinta e sacrificabile.

La Track B viene costruita soltanto dopo `LOGGING-READY` e dopo il completamento end-to-end del primo caso benigno nella Track A.

## Stato sintetico

| Fase | Stato | Evidenza principale | Prossima azione |
|---|---|---|---|
| Fase 0 — Governance | IN PROGRESS | storage privato e `.gitignore` verificati | publication checklist di prova |
| Fase 1 — Metodo analitico | NOT STARTED | - | compilare scheda A/B/C |
| Fase 2 — Topologia e rete Track A | IN PROGRESS | `ENV-2026-03`…`ENV-2026-11` | cleanup globale e inventario snapshot finale |
| Fase 3 — Raccolta e baseline Track A | IN PROGRESS | retention + rollback coordinato | cleanup/baseline e snapshot finali |
| Fase 4 — Detection engineering Track A | IN PROGRESS | TP/TN + metriche + repeatability PASS | snapshot finali `LOGGING-READY` |
| Primo caso Track A | BLOCKED | - | attendere `LOGGING-READY` |
| Track B — Malware analysis | PLANNED / BLOCKED | metodologia pubblica definita | attendere primo caso Track A completo |
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
- `ENV-2026-11` — rollback coordinato e repeatability rappresentativa 8/8, PASS.

Evidenze:

- `evidence/sanitized/ENV-2026-08-retention-baseline.md`;
- `evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md`;
- `evidence/sanitized/ENV-2026-10-detection-metrics.md`;
- `evidence/sanitized/ENV-2026-11-rollback-repeatability.md`.

## Fase 0 — Governance del repository

- [x] Leggere `SECURITY.md`.
- [x] Definire storage privato per raw evidence.
- [x] Adottare classificazione `PUBLIC`, `SANITIZED`, `PRIVATE`.
- [ ] Compilare e archiviare la checklist di pubblicazione di prova.
- [x] Definire che campioni e materiale contaminato non entrano nel repository pubblico.

## Fase 1 — Metodo analitico

- [ ] Compilare Contesto, Catena, ATT&CK, Emulazione, Detection e Response.
- [ ] Applicare confidence A/B/C.
- [ ] Definire test positivo, test negativo, kill switch e cleanup.
- [ ] Assegnare Exercise ID e usare UTC.
- [ ] Distinguere comportamento documentato, emulato e osservato.

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
- [x] health check e connettività dopo rollback coordinato.

### Da completare

- [ ] ANALYST-LAB solo se realmente necessaria;
- [ ] consolidamento finale dell'inventario snapshot;
- [ ] snapshot finali del gate Track A.

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
- [x] rollback coordinato con verifica di stato (`ENV-2026-11`);
- [x] repeatability 8/8 sul set rappresentativo multi-pipeline (`ENV-2026-11`).

### Da completare

- [ ] verifica globale cleanup e baseline;
- [ ] snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Fase 4 — Detection engineering Track A

### Completato

- [x] regole sinkhole `100100`–`100103`;
- [x] marker PowerShell `109910`;
- [x] Audit execute `80789` con `tio_appliance_exec`;
- [x] FIM `550`, `553`, `554` Whodata;
- [x] matrice formale multi-nodo: 8 TP + 6 TN, 14/14 PASS;
- [x] cleanup FIM `deleted -> 553`;
- [x] finding test-harness PowerShell documentato;
- [x] metriche di scenario, precisione, latenza osservabile e data quality (`ENV-2026-10`);
- [x] repeatability dopo rollback su set rappresentativo (`ENV-2026-11`).

### Da completare

- [ ] pubblicare rule pack Windows dopo revisione dedicata;
- [ ] tuning per frequenza e contesto;
- [ ] snapshot finali del gate Track A.

## Gate globale Track A — LOGGING-READY

Per sbloccare il primo caso:

- [x] retention finale;
- [x] matrice TP/TN multi-nodo;
- [x] metriche di scenario, precisione, latenza osservabile e data quality;
- [x] smoke test coordinato rappresentativo dei quattro nodi;
- [x] rollback completo delle quattro VM e repeatability sul set rappresentativo;
- [ ] cleanup e controllo baseline globali;
- [ ] inventario snapshot finale;
- [ ] snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Primo caso Track A

Dopo il gate globale viene completato un solo caso interamente benigno per validare l'intero processo:

- [ ] threat intelligence e confidence A/B/C;
- [ ] emulazione con dati sintetici;
- [ ] test positivo e negativo;
- [ ] detection e tuning;
- [ ] timeline UTC ed evidenze E-001…E-006;
- [ ] cleanup;
- [ ] rollback e ripetizione;
- [ ] finding, incident response e pubblicazione sanificata.

## Track B — Malware analysis separata

**Stato:** `PLANNED / BLOCKED`  
**Metodo:** `docs/07-malware-analysis-track/README.md`

Gate di ingresso:

- [ ] Track A a `LOGGING-READY`;
- [ ] primo caso benigno completato end-to-end;
- [ ] storage privato per campioni ed evidenze contaminate;
- [ ] checklist di rischio, kill switch e destruction record;
- [ ] rete distinta senza routing verso Track A o rete reale;
- [ ] manager Wazuh e sinkhole separati;
- [ ] immagini golden e overlay sacrificabili;
- [ ] condivisioni host, clipboard e drag-and-drop disabilitati.

La dinamica Track B non è obbligatoria per tutti i casi. Campioni ad alto rischio possono essere limitati alla sola analisi statica o richiedere un host fisico dedicato.

## Sequenza operativa immediata

1. verificare cleanup e baseline globali;
2. consolidare l'inventario snapshot;
3. creare `LOGGING-READY` e `LOGGING-READY-LINUX`;
4. completare il primo caso benigno end-to-end;
5. costruire la Track B separata;
6. ripetere il primo caso con analisi statica e dinamica solo se appropriata;
7. confrontare e aggiornare le detection.
