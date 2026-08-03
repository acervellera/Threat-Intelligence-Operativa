# Roadmap operativa

La roadmap segue una dipendenza rigida: una fase si chiude solo quando la relativa Definition of Done è soddisfatta. I checkpoint parziali possono essere pubblicati come evidenze `SANITIZED`, ma non trasformano automaticamente l'intera fase in `VALIDATED`.

## Stato sintetico

| Fase | Stato | Evidenza principale | Prossima azione |
|---|---|---|---|
| Fase 0 - Governance | IN PROGRESS | storage privato e `.gitignore` verificati | completare publication checklist di prova |
| Fase 1 - Metodo analitico | NOT STARTED | - | compilare scheda A/B/C |
| Fase 2 - Topologia e rete | IN PROGRESS | `ENV-2026-03`, `ENV-2026-04` | creare WAZUH-LAB e VM rimanenti |
| Fase 3 - Raccolta e baseline | IN PROGRESS | sinkhole `SINKHOLE-READY` | installare Wazuh e acquisire JSONL |
| Fase 4 - Detection engineering | NOT STARTED | - | attendere telemetria Wazuh |
| Fasi 5-10 - Campagne | BLOCKED | - | attendere `LOGGING-READY` |
| Fase 11 - Audit finale | NOT STARTED | - | attendere completamento casi |
| Fase 12 - Portfolio | NOT STARTED | - | attendere evidenze complete |

## Checkpoint verificati

### ENV-2026-03 — Baseline isolata SINKHOLE-LAB

Pubblicato il `2026-08-03 UTC`.

- KVM/QEMU e libvirt operativi;
- rete host-only `lab-lan` su `10.10.10.0/24`;
- assenza di forwarding verso LAN reale o Internet;
- `SINKHOLE-LAB` configurata su `10.10.10.30/24`;
- NAT rimosso dopo installazione e patching;
- SSH e strumenti minimi installati;
- snapshot `CLEAN-OS` creato a VM spenta;
- report: `evidence/sanitized/ENV-2026-03-sinkhole-baseline.md`.

### ENV-2026-04 — SINKHOLE-READY

Pubblicato il `2026-08-03 UTC`.

- servizio HTTP attivo e abilitato all'avvio;
- listener limitato a `10.10.10.30:8080`;
- `GET/HEAD /heartbeat` validato;
- percorso inesistente con HTTP 404;
- POST rifiutato con HTTP 405;
- processo non-root `tio-sinkhole`;
- logging JSONL valido;
- rotazione giornaliera, retention 14 e compressione;
- health check automatico: 16 controlli superati, 0 falliti;
- test dall'host LAB con codici 200/404/405;
- snapshot interno `SINKHOLE-READY`, figlio di `CLEAN-OS`;
- report: `evidence/sanitized/ENV-2026-04-sinkhole-ready.md`.

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
- [x] Creare snapshot applicativo `SINKHOLE-READY`.

### Da completare

- [ ] Preparare WAZUH-LAB `10.10.10.40`.
- [ ] Preparare WIN11-LAB `10.10.10.20`.
- [ ] Preparare APPLIANCE-LAB `10.10.10.50`.
- [ ] Preparare ANALYST-LAB `10.10.10.60` opzionale.
- [ ] Applicare isolamento ed egress deny a tutte le VM.
- [ ] Creare snapshot `CLEAN-OS` per tutte le VM principali.
- [ ] Documentare la topologia completa con configurazioni sanificate e hash.

**Gate:** tutti i nodi principali sono isolati, ripristinabili e raggiungibili soltanto nella rete LAB.

## Fase 3 - Raccolta e baseline

### Componente sinkhole completata

- [x] Implementare il sinkhole HTTP su `10.10.10.30:8080`.
- [x] Esporre esclusivamente l'endpoint benigno `/heartbeat`.
- [x] Consentire soltanto GET e HEAD.
- [x] Rifiutare POST, PUT, PATCH e DELETE con HTTP 405.
- [x] Registrare le richieste in formato JSONL.
- [x] Gestire il processo tramite utente dedicato e servizio `systemd`.
- [x] Applicare hardening minimo con `systemd`.
- [x] Configurare `logrotate` giornaliero con retention di 14 archivi.
- [x] Validare test positivo 200 e test negativi 404/405.
- [x] Validare richieste dall'host `10.10.10.1`.
- [x] Pubblicare servizio, unità, policy logrotate e health check sanificati.

### Prossimo checkpoint — WAZUH-LAB

- [ ] Creare WAZUH-LAB con 4 vCPU e 8-12 GiB RAM.
- [ ] Usare NAT soltanto per installazione e aggiornamento.
- [ ] Configurare IP statico `10.10.10.40/24` senza gateway LAB.
- [ ] Installare Wazuh all-in-one.
- [ ] Rimuovere la scheda NAT e verificare egress deny.
- [ ] Definire retention adatta al laboratorio.
- [ ] Acquisire `/var/log/tio-sinkhole/requests.jsonl`.
- [ ] Verificare parsing dei campi JSON.

### Telemetria completa

- [ ] Registrare agent Windows e Linux.
- [ ] Installare e testare Sysmon.
- [ ] Abilitare PowerShell Script Block Logging.
- [ ] Abilitare Task Scheduler Operational e auditing 4698/4699.
- [ ] Configurare auditd e FIM sull'appliance.
- [ ] Creare dataset sintetico.
- [ ] Verificare `/heartbeat` da WIN11-LAB.
- [ ] Eseguire smoke test end-to-end.
- [ ] Ripetere il test dopo rollback.
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
| 1-3 | Rete, sinkhole, Wazuh, Sysmon, logging e snapshot | Health check + smoke test | IN PROGRESS; sinkhole ready |
| 4-6 | CaptiveCrunch | Timeline + finding | BLOCKED |
| 7-10 | ACR Chain A/B | Process tree + tuning notes | BLOCKED |
| 11-14 | UNC1069 | Manifest analysis + IR scope | BLOCKED |
| 15-18 | UNC3753 | DLP/egress use case + executive summary | BLOCKED |
| 19-22 | BRICKSTORM | Appliance hardening checklist | BLOCKED |
| 23-25 | WinRAR | Detection + compliance query | BLOCKED |
| 26-28 | Test negativi, metriche e cleanup | Matrice test completa | NOT STARTED |
| 29-30 | Portfolio e colloquio | Repository finalizzato | NOT STARTED |
