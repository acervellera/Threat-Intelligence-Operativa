# Roadmap operativa

La roadmap segue una dipendenza rigida: una fase si chiude solo quando la relativa Definition of Done è soddisfatta. I checkpoint parziali possono essere pubblicati come evidenze `SANITIZED`, ma non trasformano automaticamente l'intera fase in `VALIDATED`.

## Stato sintetico

| Fase | Stato | Evidenza principale | Prossima azione |
|---|---|---|---|
| Fase 0 — Governance | IN PROGRESS | storage privato e `.gitignore` verificati | completare publication checklist di prova |
| Fase 1 — Metodo analitico | NOT STARTED | - | compilare scheda A/B/C |
| Fase 2 — Topologia e rete | IN PROGRESS | `ENV-2026-03`…`ENV-2026-07` | consolidare topologia e rollback globale |
| Fase 3 — Raccolta e baseline | IN PROGRESS | Windows, sinkhole, auditd e FIM Whodata isolati | definire retention e ripetere dopo rollback |
| Fase 4 — Detection engineering | IN PROGRESS | regole sinkhole, marker Windows e Audit rule `80789` | completare TP/TN e metriche |
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

- WIN11-LAB con Sysmon, PowerShell 4104, Task Scheduler e Security 4698/4699;
- dataset sintetico con integrità 27/27;
- NTP interno `10.10.10.1`;
- smoke test Windows → Wazuh e Windows → sinkhole senza NAT;
- snapshot `WIN11-TELEMETRY-READY`, `WAZUH-TELEMETRY-READY` e `SINKHOLE-TELEMETRY-READY`.

Evidenza: `evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`.

### ENV-2026-07 — APPLIANCE-TELEMETRY-READY

- APPLIANCE-LAB Ubuntu Server minimizzata su `10.10.10.50/24`;
- baseline `CLEAN-OS`;
- auditd e `audispd-plugins`;
- Wazuh Agent `003` Active;
- audit log raccolto e rule `80789` per `tio_appliance_exec`;
- FIM realtime Whodata su `/opt/tio-appliance-lab/data`;
- rules `554`, `550`, `553` per added/modified/deleted;
- test negativo FIM fuori perimetro;
- recovery SCA `35752` e `35754`;
- NAT rimossa, zero default route, NTP interno;
- test Audit/FIM completamente isolato;
- snapshot `APPLIANCE-TELEMETRY-READY`.

Evidenza: `evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md`.

## Fase 0 — Governance del repository

- [x] Leggere `SECURITY.md`.
- [x] Definire storage privato per raw evidence.
- [x] Adottare classificazione `PUBLIC`, `SANITIZED`, `PRIVATE`.
- [ ] Compilare e archiviare la checklist di pubblicazione di prova.

**Gate:** nessun dato reale entra nel repository.

## Fase 1 — Metodo analitico

- [ ] Compilare Contesto, Catena, ATT&CK, Emulazione, Detection e Response.
- [ ] Applicare confidence A/B/C.
- [ ] Definire test positivo, test negativo, kill switch e cleanup.
- [ ] Assegnare un Exercise ID e usare UTC.

**Gate:** scheda pre-lab revisionata.

## Fase 2 — Topologia e rete

### Completato

- [x] Installare e validare KVM/QEMU con libvirt.
- [x] Creare rete host-only `10.10.10.0/24` senza forwarding.
- [x] Preparare WIN11-LAB `10.10.10.20`.
- [x] Preparare SINKHOLE-LAB `10.10.10.30`.
- [x] Preparare WAZUH-LAB `10.10.10.40`.
- [x] Preparare APPLIANCE-LAB `10.10.10.50`.
- [x] Rimuovere NAT dai quattro nodi principali.
- [x] Verificare assenza di default route.
- [x] Configurare NTP interno `10.10.10.1`.
- [x] Creare snapshot `*-TELEMETRY-READY` dei quattro nodi.

### Da completare

- [ ] Preparare ANALYST-LAB `10.10.10.60` solo se realmente necessaria.
- [ ] Documentare l'inventario globale degli snapshot.
- [ ] Ripetere health check e connettività dopo rollback coordinato.

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
- [x] auditd su APPLIANCE-LAB.
- [x] raccolta `audit.log` e mapping CDB della chiave execution.
- [x] Wazuh FIM realtime Whodata.
- [x] test positivi e negativi Windows e Linux.
- [x] smoke test isolati e snapshot per singolo nodo.

### Da completare

- [ ] Definire retention finale di laboratorio.
- [ ] Eseguire smoke test coordinato dei quattro nodi.
- [ ] Ripetere il test completo dopo rollback.
- [ ] Creare snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

**Gate:** eventi e campi necessari sono visibili nel dashboard e il test è ripetibile dopo rollback.

## Fase 4 — Nucleo detection engineering

### Completato per i checkpoint tecnici

- [x] Regole sinkhole `100100`–`100103`.
- [x] Marker PowerShell 4104 `109910`.
- [x] Audit execute watch `80789` con `tio_appliance_exec`.
- [x] FIM rules `550`, `553`, `554` in modalità Whodata.
- [x] Test negativi selettivi Sysmon e FIM.
- [x] Alert reali in CLI e dashboard.

### Da completare

- [ ] Pubblicare rule pack Windows dopo revisione dedicata.
- [ ] Eseguire matrice TP1, TP2, TN1 e TN2 multi-nodo.
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

1. definire retention finale;
2. costruire matrice TP/TN multi-nodo;
3. misurare latency, coverage, precision e data quality;
4. eseguire smoke test coordinato dei quattro nodi;
5. ripetere tutto dopo rollback;
6. verificare cleanup e inventario snapshot;
7. creare `LOGGING-READY` e `LOGGING-READY-LINUX`;
8. sbloccare le campagne.
