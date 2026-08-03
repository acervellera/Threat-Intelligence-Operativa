# Roadmap operativa

La roadmap segue una dipendenza rigida: una fase si chiude solo quando la relativa Definition of Done è soddisfatta.

## Fase 0 - Governance del repository

- [ ] Leggere `SECURITY.md`.
- [ ] Definire storage privato per raw evidence.
- [ ] Adottare classificazione `PUBLIC`, `SANITIZED`, `PRIVATE`.
- [ ] Compilare la checklist di pubblicazione di prova.

**Gate:** nessun dato reale entra nel repository.

## Fase 1 - Metodo analitico

- [ ] Compilare le sei sezioni: Contesto, Catena, ATT&CK, Emulazione, Detection, Response.
- [ ] Applicare confidence A/B/C.
- [ ] Definire test positivo, test negativo, kill switch e cleanup.
- [ ] Assegnare un Exercise ID e usare UTC.

**Gate:** scheda pre-lab revisionata.

## Fase 2 - Topologia e rete

- [ ] Creare rete host-only `10.10.10.0/24`.
- [ ] Preparare WIN11-LAB `10.10.10.20`.
- [ ] Preparare SINKHOLE-LAB `10.10.10.30`.
- [ ] Preparare WAZUH-LAB `10.10.10.40`.
- [ ] Preparare APPLIANCE-LAB `10.10.10.50`.
- [ ] Preparare ANALYST-LAB `10.10.10.60` opzionale.
- [ ] Applicare egress deny e disabilitare NAT prima dei test.
- [ ] Creare snapshot `CLEAN-OS`.

**Gate:** nodi isolati e raggiungibili solo nella rete LAB.

## Fase 3 - Raccolta e baseline

- [ ] Installare Wazuh e registrare agent Windows/Linux.
- [ ] Installare e testare Sysmon.
- [ ] Abilitare PowerShell Script Block Logging.
- [ ] Abilitare Task Scheduler Operational e auditing 4698/4699.
- [ ] Configurare auditd e FIM sull'appliance.
- [ ] Creare dataset sintetico.
- [ ] Avviare sinkhole e verificare `/heartbeat`.
- [ ] Eseguire smoke test end-to-end.
- [ ] Creare snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

**Gate:** eventi e campi necessari sono visibili nel dashboard.

## Fase 4 - Nucleo detection engineering

- [ ] Salvare evento raw del test positivo.
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

| Giorni | Attività | Deliverable |
|---|---|---|
| 1-3 | Rete, Wazuh, Sysmon, logging e snapshot | Health screenshot + smoke test |
| 4-6 | CaptiveCrunch | Timeline + finding |
| 7-10 | ACR Chain A/B | Process tree + tuning notes |
| 11-14 | UNC1069 | Manifest analysis + IR scope |
| 15-18 | UNC3753 | DLP/egress use case + executive summary |
| 19-22 | BRICKSTORM | Appliance hardening checklist |
| 23-25 | WinRAR | Detection + compliance query |
| 26-28 | Test negativi, metriche e cleanup | Matrice test completa |
| 29-30 | Portfolio e colloquio | Repository finalizzato |
