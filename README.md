# Threat Intelligence Operativa

Percorso pubblico e progressivo per trasformare fonti di threat intelligence in laboratori difensivi ripetibili, telemetria, detection engineering, evidenze verificabili e reporting professionale.

> La Track A riproduce comportamenti osservabili e post-condizioni con artefatti benigni e sintetici. Una futura Track B, separata e sacrificabile, potrà confrontare questi risultati con analisi statica e dinamica controllata di campioni reali. Il repository pubblico non ospita malware, exploit operativi, credenziali o materiale contaminato.

## Stato corrente

**Fase primaria attiva:** `STEP-02 — Rete e VM`  
**Attività parallele:** `STEP-03 — Baseline telemetria`, `STEP-04 — Detection engineering`  
**Checkpoint più recente:** `ENV-2026-09 — matrice formale TP/TN multi-nodo`  
**Retention finale:** `PASS`  
**Matrice TP/TN:** `14/14 PASS`  
**Quattro nodi principali:** `TELEMETRY-READY per nodo`  
**Snapshot globale LOGGING-READY:** `NOT READY`  
**Track B malware analysis:** `PLANNED / BLOCKED`  
**Data:** `2026-08-07 UTC`

Completato e verificato:

- KVM/QEMU con libvirt e rete host-only `lab-lan` su `10.10.10.0/24`, senza forwarding;
- NTP interno sull'host `10.10.10.1`;
- WIN11-LAB `10.10.10.20`, SINKHOLE-LAB `10.10.10.30`, WAZUH-LAB `10.10.10.40`, APPLIANCE-LAB `10.10.10.50`;
- quattro nodi isolati, senza default route durante i test finali;
- Wazuh manager/indexer/dashboard/Filebeat e agent `001/002/003` operativi;
- sinkhole HTTP benigno con JSONL e regole `100101/100102/100103`;
- Sysmon, PowerShell 4104, Task Scheduler e Security 4698/4699;
- auditd con chiave `tio_appliance_exec` e rule `80789`;
- Wazuh FIM realtime Whodata con rules `554/550/553`;
- retention finale multi-nodo (`ENV-2026-08`);
- matrice formale 8 TP + 6 TN, 14/14 PASS (`ENV-2026-09`);
- cleanup FIM `deleted -> 553` verificato;
- evidenze private centralizzate con matrice finale congelata e manifesto SHA-256 verificato.

Riferimenti principali:

- [ENV-2026-08 — retention baseline](evidence/sanitized/ENV-2026-08-retention-baseline.md);
- [ENV-2026-09 — matrice formale TP/TN](evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md);
- [baseline telemetria](docs/03-telemetry-baseline/README.md);
- [detection engineering](docs/04-detection-engineering/README.md);
- [stato complessivo](PROGRESS.md);
- [roadmap](ROADMAP.md);
- [Track B — malware analysis separata](docs/07-malware-analysis-track/README.md).

## Perché non è ancora LOGGING-READY

Retention e matrice TP/TN sono chiuse. Il gate globale richiede ancora:

- metriche formali di latency, coverage, precision, data quality e repeatability;
- smoke test coordinato dei quattro nodi;
- ripetizione completa dopo rollback;
- verifica globale cleanup e baseline;
- inventario globale degli snapshot;
- snapshot coordinati `LOGGING-READY` e `LOGGING-READY-LINUX`.

Le campagne rimangono intenzionalmente bloccate fino al superamento di questo gate.

## Checkpoint disponibili

| Exercise ID | Ambito | Esito |
|---|---|---|
| `ENV-2026-03` | baseline isolata SINKHOLE-LAB | PASS |
| `ENV-2026-04` | sinkhole HTTP/JSONL e `SINKHOLE-READY` | PASS |
| `ENV-2026-05` | pipeline Wazuh ↔ sinkhole isolata | PASS |
| `ENV-2026-06` | telemetria Windows + sinkhole + Wazuh | PASS parziale |
| `ENV-2026-07` | auditd + FIM Whodata appliance | PASS parziale |
| `ENV-2026-08` | retention finale multi-nodo | PASS |
| `ENV-2026-09` | matrice formale TP/TN multi-nodo | PASS |

## Risultato ENV-2026-09

La matrice formale contiene 14 test: 8 true positive e 6 true negative.

| Area | Validazione |
|---|---|
| Windows PowerShell | `4104 -> 109910` positivo e negativo selettivo |
| Windows Scheduled Task | `106 -> 67014`, `4698 -> 60228`, cleanup `141 -> 67015` |
| Sinkhole | 200/404/405 con `100101/100102/100103` e TN selettivi |
| Audit Linux | `tio_appliance_exec -> 80789` e TN fuori watch |
| FIM Linux | `added -> 554`, `modified -> 550`, TN fuori path, cleanup `deleted -> 553` |

Un finding metodologico importante riguarda PowerShell: i comandi diagnostici contenenti letteralmente il trigger possono essere registrati a loro volta come 4104 e generare alert del test harness. Gli artefatti sono stati separati dall'evento intenzionale e il metodo di verifica è stato corretto.

## Topologia Track A

| Nodo | Indirizzo | Ruolo | Stato |
|---|---|---|---|
| Host Ubuntu / bridge libvirt | `10.10.10.1` | gestione locale e NTP interno | VALIDATED |
| WIN11-LAB | `10.10.10.20` | Sysmon, PowerShell, Task Scheduler, Wazuh Agent | `WIN11-TELEMETRY-READY` |
| SINKHOLE-LAB | `10.10.10.30` | HTTP interno, heartbeat e JSONL | `SINKHOLE-TELEMETRY-READY` |
| WAZUH-LAB | `10.10.10.40` | manager, indexer, dashboard e Filebeat | `WAZUH-TELEMETRY-READY` |
| APPLIANCE-LAB | `10.10.10.50` | auditd, FIM Whodata e telemetria Linux | `APPLIANCE-TELEMETRY-READY` |
| ANALYST-LAB | `10.10.10.60` | analisi e reporting, opzionale | NOT STARTED |

## Ordine operativo

### Track A

1. completare metriche, smoke test coordinato e rollback;
2. creare `LOGGING-READY` e `LOGGING-READY-LINUX`;
3. completare il primo caso interamente benigno, con detection, evidenze, cleanup, rollback e report;
4. validare la ripetibilità end-to-end.

### Track B

5. costruire una sandbox distinta senza routing verso Track A, Internet o LAN reale;
6. ripetere il primo caso iniziando dall'analisi statica;
7. eseguire dinamica soltanto quando appropriata e proporzionata;
8. confrontare comportamento documentato, emulato e osservato;
9. aggiornare detection, gap, tuning e report.

La Track B resta `BLOCKED` finché Track A non raggiunge `LOGGING-READY` e il primo caso benigno non viene completato end-to-end. Le due track non devono essere accese contemporaneamente sullo stesso host.

## Casi pianificati

1. CaptiveCrunch / Storm-2945
2. ACR Stealer — Chain A e Chain B
3. UNC1069 — fake meeting e browser extension
4. UNC3753 / Luna Moth — vishing, RMM e data theft
5. BRICKSTORM — appliance Linux/vSphere
6. WinRAR CVE-2025-8088 — ADS e Startup persistence

Ogni caso deve produrre brief, timeline, mapping MITRE ATT&CK, runbook, telemetria, evidenze, detection, test positivo e negativo, cleanup, finding e scheda incident response.

## Struttura

```text
.
├── docs/        metodo, ambiente, telemetria, detection, Track B, reporting, pubblicazione
├── labs/        percorso ambiente + sei campagne
├── templates/   modelli riutilizzabili
├── evidence/    sole evidenze sanificate e manifest pubblici
├── configs/     configurazioni didattiche validate e senza segreti
├── scripts/     script benigni, cleanup e raccolta controllata
├── sources/     indice delle fonti e note di attribuzione
└── .github/     template per issue e pull request
```

## Regola di pubblicazione

Il repository contiene soltanto materiale **PUBLIC** o **SANITIZED**. Non caricare credenziali, token, dati reali, identificatori dell'host, log completi non revisionati, immagini disco, campioni malware, payload, archivi infetti, URL operativi o snapshot contaminati. Le evidenze raw restano nello storage privato.

## Licenza

Nessuna licenza è ancora stata scelta. Fino all'aggiunta di un file `LICENSE`, il contenuto rimane protetto dal diritto d'autore e non concede automaticamente diritti di riutilizzo.
