# Roadmap operativa

La roadmap segue una dipendenza rigida: una fase si chiude solo quando la relativa Definition of Done è soddisfatta. I checkpoint parziali possono essere pubblicati come evidenze `SANITIZED`, ma non trasformano automaticamente l'intera fase in `VALIDATED`.

## Stato sintetico

| Fase | Stato | Evidenza principale | Prossima azione |
|---|---|---|---|
| Fase 0 - Governance | IN PROGRESS | storage privato e `.gitignore` verificati | completare publication checklist di prova |
| Fase 1 - Metodo analitico | NOT STARTED | - | compilare scheda A/B/C |
| Fase 2 - Topologia e rete | IN PROGRESS | `ENV-2026-03` | completare VM rimanenti |
| Fase 3 - Raccolta e baseline | NOT STARTED | - | implementare sinkhole HTTP e Wazuh |
| Fase 4 - Detection engineering | NOT STARTED | - | attendere telemetria |
| Fasi 5-10 - Campagne | NOT STARTED | - | attendere `LOGGING-READY` |
| Fase 11 - Audit finale | NOT STARTED | - | attendere completamento casi |
| Fase 12 - Portfolio | NOT STARTED | - | attendere evidenze complete |

## Ultimo checkpoint verificato

`ENV-2026-03 — Baseline isolata SINKHOLE-LAB`, pubblicato il `2026-08-03 UTC`.

Risultati:

- KVM/QEMU e libvirt operativi;
- rete host-only `lab-lan` su `10.10.10.0/24`;
- assenza di forwarding verso LAN reale o Internet;
- `SINKHOLE-LAB` configurata su `10.10.10.30/24`;
- NAT rimosso dopo installazione e patching;
- SSH e strumenti minimi installati;
- snapshot `CLEAN-OS` creato a VM spenta;
- report pubblico sanificato disponibile in `evidence/sanitized/ENV-2026-03-sinkhole-baseline.md`.

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
- [x] Rimuovere il NAT da SINKHOLE-LAB dopo il patching.
- [x] Verificare egress deny su SINKHOLE-LAB.
- [x] Creare snapshot `CLEAN-OS` di SINKHOLE-LAB.

### Da completare

- [ ] Preparare WIN11-LAB `10.10.10.20`.
- [ ] Preparare WAZUH-LAB `10.10.10.40`.
- [ ] Preparare APPLIANCE-LAB `10.10.10.50`.
- [ ] Preparare ANALYST-LAB `10.10.10.60` opzionale.
- [ ] Applicare isolamento ed egress deny a tutte le VM.
- [ ] Creare snapshot `CLEAN-OS` per tutte le VM principali.
- [ ] Documentare la topologia completa con configurazioni sanificate e hash.

**Gate:** tutti i nodi principali sono isolati, ripristinabili e raggiungibili soltanto nella rete LAB.

## Fase 3 - Raccolta e baseline

### Prossimo checkpoint operativo

- [ ] Implementare il sinkhole HTTP su `10.10.10.30:8080`.
- [ ] Esporre esclusivamente l'endpoint benigno `/heartbeat`.
- [ ] Registrare le richieste in formato JSONL.
- [ ] Gestire il processo tramite un servizio `systemd` dedicato.
- [ ] Verificare che il servizio non esegua upload, payload o comandi.

### Telemetria completa

- [ ] Installare Wazuh e registrare agent Windows/Linux.
- [ ] Installare e testare Sysmon.
- [ ] Abilitare PowerShell Script Block Logging.
- [ ] Abilitare Task Scheduler Operational e auditing 4698/4699.
- [ ] Configurare auditd e FIM sull'appliance.
- [ ] Creare dataset sintetico.
- [ ] Verificare `/heartbeat` da WIN11-LAB.
- [ ] Eseguire smoke test end-to-end.
- [ ] Creare snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

**Gate:** eventi e campi necessari sono visibili nel dashboard e il test è ripetibile dopo rollback.

## Fase 4 - Nucleo detection engineering

- [ ] Salvare evento raw del test positivo nello storage privato.
- [ ] Scrivere regola su campi stabili.
- [ ] Testare con `wazuh-logtest`.
- [ ] Eseguire almeno due test negativi.
- [ ] Misurare latency, coverage, precision, data quality, repeatability e cleanup completeness.

**Gate:** detection ripetibile e contestualizzata.

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
| 1-3 | Rete, Wazuh, Sysmon, logging e snapshot | Health screenshot + smoke test | IN PROGRESS |
| 4-6 | CaptiveCrunch | Timeline + finding | NOT STARTED |
| 7-10 | ACR Chain A/B | Process tree + tuning notes | NOT STARTED |
| 11-14 | UNC1069 | Manifest analysis + IR scope | NOT STARTED |
| 15-18 | UNC3753 | DLP/egress use case + executive summary | NOT STARTED |
| 19-22 | BRICKSTORM | Appliance hardening checklist | NOT STARTED |
| 23-25 | WinRAR | Detection + compliance query | NOT STARTED |
| 26-28 | Test negativi, metriche e cleanup | Matrice test completa | NOT STARTED |
| 29-30 | Portfolio e colloquio | Repository finalizzato | NOT STARTED |
