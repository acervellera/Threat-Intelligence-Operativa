# Threat Intelligence Operativa

Percorso pubblico e progressivo per trasformare fonti di threat intelligence in laboratori difensivi ripetibili, telemetria, detection engineering, evidenze verificabili e reporting professionale.

> La Track A riproduce comportamenti osservabili e post-condizioni con artefatti benigni e sintetici. Una futura Track B, separata e sacrificabile, potrà confrontare questi risultati con analisi statica e dinamica controllata di campioni reali. Il repository pubblico non ospita malware, exploit operativi, credenziali o materiale contaminato.

## Stato corrente

**Gate infrastrutturale Track A:** `LOGGING-READY — PASS`  
**Checkpoint più recente:** `ENV-2026-13 — snapshot finali LOGGING-READY`  
**Retention finale:** `PASS`  
**Matrice TP/TN:** `14/14 PASS`  
**Metriche formali:** `PASS`  
**Repeatability rappresentativa:** `8/8 PASS dopo rollback`  
**Cleanup globale:** `PASS`  
**WIN11-LAB:** `LOGGING-READY`  
**Nodi Linux:** `LOGGING-READY-LINUX`  
**CASE-01:** `READY / NEXT`  
**Track B malware analysis:** `PLANNED / BLOCKED` fino al completamento del primo caso Track A  
**Data:** `2026-08-10 UTC`

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
- metriche di scenario, precisione alert, latenza osservabile e qualità dei dati (`ENV-2026-10`);
- baseline coordinata, rollback reale e repeatability 8/8 sul set rappresentativo (`ENV-2026-11`);
- cleanup globale e health check finale (`ENV-2026-12`);
- inventario snapshot finale e baseline `LOGGING-READY` / `LOGGING-READY-LINUX` (`ENV-2026-13`);
- evidenze private congelate con manifesti SHA-256 verificati.

Riferimenti principali:

- [ENV-2026-08 — retention baseline](evidence/sanitized/ENV-2026-08-retention-baseline.md);
- [ENV-2026-09 — matrice formale TP/TN](evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md);
- [ENV-2026-10 — metriche di detection](evidence/sanitized/ENV-2026-10-detection-metrics.md);
- [ENV-2026-11 — rollback e ripetibilità](evidence/sanitized/ENV-2026-11-rollback-repeatability.md);
- [ENV-2026-12 — cleanup globale](evidence/sanitized/ENV-2026-12-cleanup-baseline.md);
- [ENV-2026-13 — LOGGING-READY](evidence/sanitized/ENV-2026-13-logging-ready.md);
- [baseline telemetria](docs/03-telemetry-baseline/README.md);
- [detection engineering](docs/04-detection-engineering/README.md);
- [stato complessivo](PROGRESS.md);
- [roadmap](ROADMAP.md);
- [Track B — malware analysis separata](docs/07-malware-analysis-track/README.md).

## Gate LOGGING-READY

Il gate infrastrutturale Track A è chiuso. La catena di validazione comprende:

```text
TELEMETRY-READY
      ↓
retention
      ↓
TP/TN formali
      ↓
metriche
      ↓
rollback + repeatability
      ↓
cleanup globale
      ↓
LOGGING-READY
```

`LOGGING-READY` non significa copertura universale ATT&CK o equivalenza con un SOC di produzione. Significa che questa infrastruttura di laboratorio dispone di una baseline finale ripristinabile e verificata per iniziare il primo caso benigno end-to-end.

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
| `ENV-2026-10` | metriche di detection e qualità dei dati | PASS |
| `ENV-2026-11` | rollback coordinato e repeatability rappresentativa | PASS |
| `ENV-2026-12` | cleanup globale e health check finale | PASS |
| `ENV-2026-13` | snapshot finali `LOGGING-READY` | PASS |

## Risultati quantitativi

`ENV-2026-10/11` misura esclusivamente il set controllato del laboratorio.

| Metrica | Risultato |
|---|---:|
| Completamento scenari | 14/14 — 100,00% |
| Efficacia True Positive | 8/8 — 100,00% |
| Selettività True Negative | 6/6 — 100,00% |
| Precisione grezza degli alert | 76,92% |
| Precisione classificata sul set controllato | 100,00% |
| Latenza mediana osservabile | 1,034 s |
| Completezza campi definiti per triage | 68/68 — 100,00% |
| Repeatability rappresentativa dopo rollback | 8/8 — 100,00% |

I valori al 100% non equivalgono a copertura MITRE ATT&CK, precisione di produzione o prestazioni universali di Wazuh. La precisione grezza conserva tre artefatti noti del test harness PowerShell; i due scenari FIM non sono inclusi nelle statistiche di latenza perché non disponevano di una coppia di timestamp sorgente/alert sufficientemente omogenea.

## Topologia Track A

| Nodo | Indirizzo | Ruolo | Baseline finale |
|---|---|---|---|
| Host Ubuntu / bridge libvirt | `10.10.10.1` | gestione locale e NTP interno | VALIDATED |
| WIN11-LAB | `10.10.10.20` | Sysmon, PowerShell, Task Scheduler, Wazuh Agent | `LOGGING-READY` |
| SINKHOLE-LAB | `10.10.10.30` | HTTP interno, heartbeat e JSONL | `LOGGING-READY-LINUX` |
| WAZUH-LAB | `10.10.10.40` | manager, indexer, dashboard e Filebeat | `LOGGING-READY-LINUX` |
| APPLIANCE-LAB | `10.10.10.50` | auditd, FIM Whodata e telemetria Linux | `LOGGING-READY-LINUX` |
| ANALYST-LAB | `10.10.10.60` | analisi e reporting, opzionale | NOT STARTED |

## Ordine operativo

### Track A

1. completare `CASE-01 — CaptiveCrunch / Storm-2945` in modo interamente benigno;
2. produrre threat-intelligence brief, confidence A/B/C, mapping ATT&CK e piano di emulazione;
3. eseguire detection, TP/TN, timeline, evidence register, cleanup e rollback;
4. validare la ripetibilità end-to-end e pubblicare il caso sanificato.

### Track B

5. solo dopo il primo caso Track A completo, costruire una sandbox distinta senza routing verso Track A, Internet o LAN reale;
6. ripetere il primo caso iniziando dall'analisi statica;
7. eseguire dinamica soltanto quando appropriata e proporzionata;
8. confrontare comportamento documentato, emulato e osservato;
9. aggiornare detection, gap, tuning e report.

La Track B resta `BLOCKED` finché il primo caso Track A non viene completato end-to-end. Le due track non devono essere accese contemporaneamente sullo stesso host.

## Casi pianificati

1. **CaptiveCrunch / Storm-2945 — READY / NEXT**
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
