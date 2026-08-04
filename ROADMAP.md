# Roadmap operativa

La roadmap segue una dipendenza rigida: una fase si chiude solo quando la relativa Definition of Done è soddisfatta. I checkpoint parziali possono essere pubblicati come evidenze `SANITIZED`, ma non trasformano automaticamente l'intera fase in `VALIDATED`.

## Stato sintetico

| Fase | Stato | Evidenza principale | Prossima azione |
|---|---|---|---|
| Fase 0 - Governance | IN PROGRESS | storage privato e `.gitignore` verificati | completare publication checklist di prova |
| Fase 1 - Metodo analitico | NOT STARTED | - | compilare scheda A/B/C |
| Fase 2 - Topologia e rete | IN PROGRESS | `ENV-2026-03`, `ENV-2026-04`, `ENV-2026-05` | isolare WAZUH-LAB e creare WIN11-LAB |
| Fase 3 - Raccolta e baseline | IN PROGRESS | pipeline Linux/JSONL validata | aggiungere telemetria Windows e appliance |
| Fase 4 - Detection engineering | IN PROGRESS | regole sinkhole 100101-100103 | completare test negativi, metriche e rollback |
| Fasi 5-10 - Campagne | BLOCKED | - | attendere `LOGGING-READY` |
| Fase 11 - Audit finale | NOT STARTED | - | attendere completamento casi |
| Fase 12 - Portfolio | NOT STARTED | - | attendere evidenze complete |

## Checkpoint verificati

### ENV-2026-03 — Baseline isolata SINKHOLE-LAB

Pubblicato il `2026-08-03 UTC`.

- KVM/QEMU e libvirt operativi;
- rete host-only `lab-lan` su `10.10.10.0/24`;
- SINKHOLE-LAB su `10.10.10.30/24` senza NAT e senza default route;
- snapshot `CLEAN-OS`;
- report: `evidence/sanitized/ENV-2026-03-sinkhole-baseline.md`.

### ENV-2026-04 — SINKHOLE-READY

Pubblicato il `2026-08-03 UTC`.

- servizio HTTP su `10.10.10.30:8080`;
- test 200/404/405;
- processo non-root;
- JSONL e logrotate;
- health check 16 PASS / 0 FAIL;
- snapshot `SINKHOLE-READY`;
- report: `evidence/sanitized/ENV-2026-04-sinkhole-ready.md`.

### ENV-2026-05 — Pipeline Wazuh ↔ sinkhole

Pubblicato il `2026-08-04 UTC`.

- WAZUH-LAB su Ubuntu Server 24.04 LTS e `10.10.10.40/24`;
- manager, indexer, dashboard e Filebeat attivi;
- cluster indexer green;
- snapshot `CLEAN-OS` e `WAZUH-READY`;
- agent `sinkhole-lab` Active tramite `lab-lan`;
- SINKHOLE-LAB nuovamente priva di NAT e default route;
- ingestione di `/var/log/tio-sinkhole/requests.jsonl`;
- parsing JSON e label contestuali;
- regole custom 100101, 100102 e 100103 validate;
- alert 200/404/405 verificati fino al dashboard;
- report: `evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`.

## Fase 0 - Governance del repository

- [x] Leggere `SECURITY.md`.
- [x] Definire storage privato per raw evidence.
- [x] Adottare classificazione `PUBLIC`, `SANITIZED`, `PRIVATE`.
- [ ] Compilare e archiviare la checklist di pubblicazione di prova.

**Gate:** nessun dato reale entra nel repository.

## Fase 1 - Metodo analitico

- [ ] Compilare le sei sezioni: Contesto, Catena, ATT&CK, Emulazione, Detection, Response.
- [ ] Applicare confidence A/B/C.
- [ ] Definire test positivo, test negativo, kill switch e cleanup.
- [ ] Assegnare un Exercise ID e usare UTC.

**Gate:** scheda pre-lab revisionata.

## Fase 2 - Topologia e rete

### Completato

- [x] Installare e validare KVM/QEMU con libvirt.
- [x] Creare rete host-only `10.10.10.0/24`.
- [x] Verificare assenza di bridge verso LAN reale.
- [x] Preparare SINKHOLE-LAB `10.10.10.30`.
- [x] Rimuovere il NAT da SINKHOLE-LAB dopo patching e installazione agent.
- [x] Verificare egress deny su SINKHOLE-LAB.
- [x] Creare snapshot `CLEAN-OS` e `SINKHOLE-READY` di SINKHOLE-LAB.
- [x] Preparare WAZUH-LAB `10.10.10.40`.
- [x] Creare snapshot `CLEAN-OS` e `WAZUH-READY` di WAZUH-LAB.

### Da completare

- [ ] Rimuovere la NIC NAT temporanea da WAZUH-LAB.
- [ ] Verificare egress deny e servizi Wazuh dopo isolamento e riavvio.
- [ ] Preparare WIN11-LAB `10.10.10.20`.
- [ ] Preparare APPLIANCE-LAB `10.10.10.50`.
- [ ] Preparare ANALYST-LAB `10.10.10.60` opzionale.
- [ ] Applicare isolamento ed egress deny a tutte le VM.
- [ ] Creare snapshot `CLEAN-OS` per le VM rimanenti.
- [ ] Documentare la topologia completa con configurazioni sanificate e hash.

**Gate:** tutti i nodi principali sono isolati, ripristinabili e raggiungibili soltanto nella rete LAB.

## Fase 3 - Raccolta e baseline

### Componente sinkhole e pipeline Linux completate

- [x] Implementare il sinkhole HTTP su `10.10.10.30:8080`.
- [x] Registrare le richieste in formato JSONL.
- [x] Configurare servizio non-root, hardening e logrotate.
- [x] Validare test 200/404/405.
- [x] Installare Wazuh all-in-one.
- [x] Registrare l'agent Linux `sinkhole-lab`.
- [x] Acquisire `/var/log/tio-sinkhole/requests.jsonl`.
- [x] Verificare parsing dei campi JSON e label.
- [x] Verificare manager, Filebeat, indexer e dashboard.

### Telemetria completa da completare

- [ ] Definire retention finale di laboratorio.
- [ ] Registrare agent Windows e appliance Linux.
- [ ] Installare e testare Sysmon.
- [ ] Abilitare PowerShell Script Block Logging.
- [ ] Abilitare Task Scheduler Operational e auditing 4698/4699.
- [ ] Configurare auditd e FIM sull'appliance.
- [ ] Creare dataset sintetico.
- [ ] Verificare `/heartbeat` da WIN11-LAB.
- [ ] Eseguire smoke test multi-sorgente end-to-end.
- [ ] Ripetere il test dopo rollback.
- [ ] Creare snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

**Gate:** eventi e campi necessari sono visibili nel dashboard e il test è ripetibile dopo rollback.

## Fase 4 - Nucleo detection engineering

### Completato per il checkpoint tecnico sinkhole

- [x] Scrivere regola padre per JSON provenienti da `requests.jsonl`.
- [x] Validare heartbeat 200 con regola `100101`.
- [x] Validare 404 con regola `100102`.
- [x] Validare 405 con regola `100103`.
- [x] Testare sintassi con `wazuh-analysisd -t`.
- [x] Testare eventi campione con `wazuh-logtest`.
- [x] Verificare gli alert nella pipeline reale e nel dashboard.

### Da completare

- [ ] Salvare evento raw del test positivo nello storage privato con manifest.
- [ ] Eseguire almeno due test negativi formali.
- [ ] Aggiungere tuning per frequenza e contesto.
- [ ] Misurare latency, coverage, precision, data quality e repeatability.
- [ ] Ripetere dopo rollback e verificare cleanup.

**Gate:** detection ripetibile, contestualizzata e misurata.

## Fasi 5-10 - Campagne

- [ ] CaptiveCrunch / Storm-2945.
- [ ] ACR Stealer Chain A e Chain B.
- [ ] UNC1069 fake meeting e browser extension.
- [ ] UNC3753 / Luna Moth.
- [ ] BRICKSTORM appliance Linux/vSphere.
- [ ] WinRAR CVE-2025-8088 ADS e Startup.

**Gate per ogni campagna:** brief, ATT&CK, runbook, E-001...E-006, detection, TP/TN, cleanup, finding e IR report.

## Fase 11 - Audit finale

- [ ] Ripetere i test da snapshot.
- [ ] Eseguire matrice TP1, TP2, TN1, TN2 e resilienza.
- [ ] Verificare nessun artefatto residuo.
- [ ] Rivedere i gap di visibilità dichiarati.

## Fase 12 - Pubblicazione portfolio

- [ ] Rimuovere dati reali e metadati.
- [ ] Sostituire identificatori con placeholder coerenti.
- [ ] Calcolare SHA-256 delle copie sanificate.
- [ ] Compilare manifest pubblico.
- [ ] Aprire pull request e completare publication gate.
- [ ] Pubblicare solo dopo review.

## Piano indicativo di 30 giorni

Il piano temporale è indicativo: i gate tecnici hanno precedenza sulle date.

| Giorni | Attività | Deliverable | Stato |
|---|---|---|---|
| 1-3 | Rete, sinkhole, Wazuh, Sysmon, logging e snapshot | Health check + smoke test | IN PROGRESS; pipeline Linux/JSONL validata |
| 4-6 | CaptiveCrunch | Timeline + finding | BLOCKED |
| 7-10 | ACR Chain A/B | Process tree + tuning notes | BLOCKED |
| 11-14 | UNC1069 | Manifest analysis + IR scope | BLOCKED |
| 15-18 | UNC3753 | DLP/egress use case + executive summary | BLOCKED |
| 19-22 | BRICKSTORM | Appliance hardening checklist | BLOCKED |
| 23-25 | WinRAR | Detection + compliance query | BLOCKED |
| 26-28 | Test negativi, metriche e cleanup | Matrice test completa | NOT STARTED |
| 29-30 | Portfolio e colloquio | Repository finalizzato | NOT STARTED |
