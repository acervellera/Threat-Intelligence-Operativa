# Roadmap operativa

La roadmap segue una dipendenza rigida: una fase si chiude solo quando la relativa Definition of Done è soddisfatta. I checkpoint parziali possono essere pubblicati come evidenze `SANITIZED`, ma non trasformano automaticamente l'intera fase in `VALIDATED`.

## Stato sintetico

| Fase | Stato | Evidenza principale | Prossima azione |
|---|---|---|---|
| Fase 0 — Governance | IN PROGRESS | storage privato e `.gitignore` verificati | completare publication checklist di prova |
| Fase 1 — Metodo analitico | NOT STARTED | - | compilare scheda A/B/C |
| Fase 2 — Topologia e rete | IN PROGRESS | `ENV-2026-03`…`ENV-2026-06` | creare APPLIANCE-LAB |
| Fase 3 — Raccolta e baseline | IN PROGRESS | pipeline Windows + Linux/JSONL isolata | aggiungere auditd e FIM appliance |
| Fase 4 — Detection engineering | IN PROGRESS | regole sinkhole e marker Windows | completare TP/TN, metriche e rollback |
| Fasi 5-10 — Campagne | BLOCKED | - | attendere `LOGGING-READY` |
| Fase 11 — Audit finale | NOT STARTED | - | attendere completamento casi |
| Fase 12 — Portfolio | NOT STARTED | - | attendere evidenze complete |

## Checkpoint verificati

### ENV-2026-03 — Baseline isolata SINKHOLE-LAB

- rete host-only `lab-lan` su `10.10.10.0/24`;
- SINKHOLE-LAB isolata;
- snapshot `CLEAN-OS`.

### ENV-2026-04 — SINKHOLE-READY

- servizio HTTP benigno;
- test 200/404/405;
- JSONL e logrotate;
- health check 16 PASS / 0 FAIL;
- snapshot `SINKHOLE-READY`.

### ENV-2026-05 — Pipeline Wazuh ↔ sinkhole isolata

- WAZUH-LAB all-in-one;
- agent Linux Active;
- acquisizione JSONL;
- regole `100100`–`100103`;
- pipeline senza egress;
- snapshot `WAZUH-PIPELINE-READY`.

### ENV-2026-06 — Telemetria multi-sorgente isolata

- WIN11-LAB con Wazuh Agent, Sysmon, PowerShell 4104 e Task Scheduler;
- auditing 4698/4699;
- dataset sintetico con integrità 27/27;
- test positivo e negativo FileCreate;
- NTP interno `10.10.10.1` per i tre nodi;
- NAT rimossa da WIN11-LAB;
- smoke test endpoint → Wazuh e endpoint → sinkhole;
- alert verificati in CLI e dashboard;
- snapshot `WIN11-TELEMETRY-READY`;
- snapshot `WAZUH-TELEMETRY-READY`;
- snapshot `SINKHOLE-TELEMETRY-READY`.

Evidenza: `evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`.

## Fase 0 — Governance del repository

- [x] Leggere `SECURITY.md`.
- [x] Definire storage privato per raw evidence.
- [x] Adottare classificazione `PUBLIC`, `SANITIZED`, `PRIVATE`.
- [ ] Compilare e archiviare la checklist di pubblicazione di prova.

**Gate:** nessun dato reale entra nel repository.

## Fase 1 — Metodo analitico

- [ ] Compilare le sei sezioni: Contesto, Catena, ATT&CK, Emulazione, Detection, Response.
- [ ] Applicare confidence A/B/C.
- [ ] Definire test positivo, test negativo, kill switch e cleanup.
- [ ] Assegnare un Exercise ID e usare UTC.

**Gate:** scheda pre-lab revisionata.

## Fase 2 — Topologia e rete

### Completato

- [x] Installare e validare KVM/QEMU con libvirt.
- [x] Creare rete host-only `10.10.10.0/24`.
- [x] Verificare assenza di bridge verso LAN reale.
- [x] Preparare SINKHOLE-LAB `10.10.10.30`.
- [x] Preparare WAZUH-LAB `10.10.10.40`.
- [x] Preparare WIN11-LAB `10.10.10.20`.
- [x] Rimuovere NAT dai tre nodi operativi.
- [x] Verificare assenza di default route.
- [x] Configurare NTP interno `10.10.10.1`.
- [x] Creare snapshot `*-TELEMETRY-READY` dei tre nodi.

### Da completare

- [ ] Preparare APPLIANCE-LAB `10.10.10.50`.
- [ ] Preparare ANALYST-LAB `10.10.10.60` opzionale.
- [ ] Applicare isolamento, NTP e snapshot ad APPLIANCE-LAB.
- [ ] Documentare la topologia completa finale.

**Gate:** tutti i nodi principali sono isolati, ripristinabili e raggiungibili soltanto nella rete LAB.

## Fase 3 — Raccolta e baseline

### Completato

- [x] Sinkhole HTTP e JSONL.
- [x] Wazuh all-in-one.
- [x] Agent Linux e Windows.
- [x] Sysmon Operational.
- [x] PowerShell Script Block Logging 4104.
- [x] Task Scheduler Operational.
- [x] auditing Security 4698/4699.
- [x] dataset sintetico e manifesto SHA-256.
- [x] test positivo e negativo FileCreate.
- [x] smoke test Windows + sinkhole + Wazuh senza NAT.
- [x] snapshot per singolo nodo.

### Da completare

- [ ] Definire retention finale di laboratorio.
- [ ] Registrare agent appliance Linux.
- [ ] Configurare auditd e Wazuh FIM.
- [ ] Eseguire smoke test comprendente l'appliance.
- [ ] Ripetere il test completo dopo rollback.
- [ ] Creare snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

**Gate:** eventi e campi necessari sono visibili nel dashboard e il test è ripetibile dopo rollback.

## Fase 4 — Nucleo detection engineering

### Completato per i checkpoint tecnici

- [x] Regola padre sinkhole `100100`.
- [x] Heartbeat 200 `100101`.
- [x] HTTP 404 `100102`.
- [x] HTTP 405 `100103`.
- [x] Marker PowerShell 4104 `109910`.
- [x] Validazione con `wazuh-analysisd -t`.
- [x] Alert reali in CLI e dashboard.
- [x] Test negativo selettivo Sysmon FileCreate.

### Da completare

- [ ] Pubblicare rule pack Windows dopo revisione dedicata.
- [ ] Eseguire matrice TP1, TP2, TN1 e TN2.
- [ ] Aggiungere tuning per frequenza e contesto.
- [ ] Misurare latency, coverage, precision, data quality e repeatability.
- [ ] Ripetere dopo rollback e verificare cleanup.

**Gate:** detection ripetibile, contestualizzata e misurata.

## Fasi 5-10 — Campagne

- [ ] CaptiveCrunch / Storm-2945.
- [ ] ACR Stealer Chain A e Chain B.
- [ ] UNC1069 fake meeting e browser extension.
- [ ] UNC3753 / Luna Moth.
- [ ] BRICKSTORM appliance Linux/vSphere.
- [ ] WinRAR CVE-2025-8088 ADS e Startup.

**Gate per ogni campagna:** brief, ATT&CK, runbook, E-001…E-006, detection, TP/TN, cleanup, finding e IR report.

## Fase 11 — Audit finale

- [ ] Ripetere i test da snapshot.
- [ ] Eseguire matrice TP1, TP2, TN1, TN2 e resilienza.
- [ ] Verificare nessun artefatto residuo.
- [ ] Rivedere i gap di visibilità dichiarati.

## Fase 12 — Pubblicazione portfolio

- [ ] Rimuovere dati reali e metadati.
- [ ] Sostituire identificatori con placeholder coerenti.
- [ ] Calcolare SHA-256 delle copie sanificate.
- [ ] Compilare manifest pubblico.
- [ ] Aprire pull request e completare publication gate.
- [ ] Pubblicare solo dopo review.

## Sequenza operativa immediata

1. creare APPLIANCE-LAB;
2. configurare auditd e Wazuh FIM;
3. integrare la quarta sorgente nel dashboard;
4. definire retention;
5. eseguire matrice TP/TN e metriche;
6. ripetere tutto dopo rollback;
7. creare `LOGGING-READY` e `LOGGING-READY-LINUX`;
8. sbloccare le campagne.
