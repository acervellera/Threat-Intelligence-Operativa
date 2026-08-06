# Threat Intelligence Operativa

Percorso pubblico e progressivo per trasformare fonti di threat intelligence in laboratori difensivi ripetibili, telemetria, detection engineering, evidenze verificabili e reporting professionale.

> Il repository riproduce comportamenti osservabili e post-condizioni, non malware, exploit operativi o furto di credenziali. Tutte le attività devono avvenire in VM isolate, con dati sintetici, snapshot e destinazioni di rete interne.

## Stato corrente

**Fase primaria attiva:** `STEP-02 — Rete e VM`  
**Attività parallele:** `STEP-03 — Baseline telemetria` e `STEP-04 — Smoke test`  
**Checkpoint più recente:** `ENV-2026-07 — APPLIANCE-LAB telemetry ready`  
**Quattro nodi principali:** `TELEMETRY-READY per nodo`  
**Snapshot finale LOGGING-READY:** `NOT READY`  
**Data:** `2026-08-06 UTC`

Completato e verificato:

- hypervisor KVM/QEMU con libvirt;
- rete host-only `lab-lan` su `10.10.10.0/24`, senza forwarding;
- server NTP interno sull'host `10.10.10.1`;
- `WIN11-LAB` su `10.10.10.20/24`, isolata e senza default route;
- `SINKHOLE-LAB` su `10.10.10.30/24`, isolata e senza default route;
- `WAZUH-LAB` su `10.10.10.40/24`, isolata e senza default route;
- `APPLIANCE-LAB` su `10.10.10.50/24`, isolata e senza default route;
- Wazuh manager, indexer, dashboard e Filebeat operativi;
- agent `sinkhole-lab`, `WIN11-LAB` e `appliance-lab` Active;
- sinkhole HTTP benigno con JSONL e test 200/404/405;
- Sysmon, PowerShell 4104, Task Scheduler e Security 4698/4699 acquisiti;
- dataset sintetico Windows con integrità 27/27;
- auditd e raccolta `/var/log/audit/audit.log` su APPLIANCE-LAB;
- alert Audit execute rule `80789` con chiave `tio_appliance_exec`;
- Wazuh FIM realtime Whodata su `/opt/tio-appliance-lab/data`;
- ciclo FIM `added`, `modified`, cambio permessi e `deleted` con rules `554`, `550`, `553`;
- test negativi selettivi Windows e FIM;
- recovery SCA dei controlli Audit `35752` e `35754`;
- smoke test end-to-end senza NAT sui nodi endpoint;
- alert verificati in `alerts.json` e nel dashboard;
- snapshot `WIN11-TELEMETRY-READY`, `SINKHOLE-TELEMETRY-READY`, `WAZUH-TELEMETRY-READY` e `APPLIANCE-TELEMETRY-READY`;
- pacchetti e manifesti privati verificati prima e dopo il trasferimento.

Riferimenti principali:

- [ENV-2026-06 — telemetria multi-sorgente isolata](evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md);
- [ENV-2026-07 — APPLIANCE-LAB telemetry ready](evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md);
- [configurazioni Wazuh validate](configs/wazuh/README.md);
- [stato complessivo](PROGRESS.md);
- [roadmap](ROADMAP.md);
- Issue `#3 — Costruire rete host-only e macchine virtuali`;
- Issue `#5 — Dataset sintetico, sinkhole e snapshot LOGGING-READY`.

**Prossimo checkpoint operativo:** consolidare retention, matrice TP/TN, metriche e ripetizione coordinata dopo rollback, quindi creare i gate globali `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Perché non è ancora LOGGING-READY

I quattro nodi principali dispongono ora di snapshot `*-TELEMETRY-READY`, ma il gate globale richiede ancora:

- retention finale;
- matrice formale TP/TN multi-nodo;
- metriche di latency, coverage, precision e data quality;
- ripetizione completa dopo rollback;
- inventario globale degli snapshot e verifica di cleanup;
- snapshot coordinati `LOGGING-READY` e `LOGGING-READY-LINUX`.

Le campagne rimangono intenzionalmente bloccate fino al superamento di questo gate.

## Obiettivo

Completare il percorso dall'allestimento del laboratorio fino alla pubblicazione di sei casi documentati:

1. CaptiveCrunch / Storm-2945
2. ACR Stealer — Chain A e Chain B
3. UNC1069 — fake meeting e browser extension
4. UNC3753 / Luna Moth — vishing, RMM e data theft
5. BRICKSTORM — appliance Linux/vSphere
6. WinRAR CVE-2025-8088 — ADS e Startup persistence

Ogni caso deve produrre brief, timeline, mapping MITRE ATT&CK, runbook, telemetria, evidenze E-001…E-006, detection, test positivo e negativo, cleanup, finding e scheda incident response.

## Topologia

| Nodo | Indirizzo | Ruolo | Stato |
|---|---|---|---|
| Host Ubuntu / bridge libvirt | `10.10.10.1` | gestione locale e NTP interno | VALIDATED |
| WIN11-LAB | `10.10.10.20` | Sysmon, PowerShell, Task Scheduler, Wazuh Agent | `WIN11-TELEMETRY-READY` |
| SINKHOLE-LAB | `10.10.10.30` | HTTP interno, heartbeat e JSONL | `SINKHOLE-TELEMETRY-READY` |
| WAZUH-LAB | `10.10.10.40` | manager, indexer, dashboard e Filebeat | `WAZUH-TELEMETRY-READY` |
| APPLIANCE-LAB | `10.10.10.50` | auditd, FIM Whodata e telemetria Linux | `APPLIANCE-TELEMETRY-READY` |
| ANALYST-LAB | `10.10.10.60` | analisi e reporting, opzionale | NOT STARTED |

La rete LAB è priva di forwarding. Le interfacce NAT sono ammesse soltanto durante installazione e aggiornamento e devono essere rimosse prima dei test.

## Checkpoint disponibili

| Exercise ID | Snapshot / ambito | Esito |
|---|---|---|
| `ENV-2026-03` | `CLEAN-OS` SINKHOLE-LAB | PASS |
| `ENV-2026-04` | `SINKHOLE-READY` | PASS |
| `ENV-2026-05` | `WAZUH-PIPELINE-READY`, pipeline Linux/JSONL isolata | PASS parziale |
| `ENV-2026-06` | Windows + sinkhole + Wazuh, NTP interno e snapshot per nodo | PASS parziale |
| `ENV-2026-07` | auditd + Wazuh FIM Whodata, isolamento e snapshot appliance | PASS parziale; non è `LOGGING-READY` |

Gli snapshot interni QCOW2 non sostituiscono un backup indipendente.

## Inizia qui

| Ordine | Fase | Cartella | Uscita richiesta | Stato corrente |
|---:|---|---|---|---|
| 0 | Governance e sicurezza | [`docs/00-governance`](docs/00-governance/README.md) | regole PUBLIC/SANITIZED/PRIVATE | IN PROGRESS |
| 1 | Metodo analitico | [`docs/01-method`](docs/01-method/README.md) | scheda A/B/C e catena neutra | NOT STARTED |
| 2 | Costruzione ambiente | [`labs/00-environment`](labs/00-environment/README.md) | topologia, snapshot e health check | IN PROGRESS |
| 3 | Baseline telemetria | [`docs/03-telemetry-baseline`](docs/03-telemetry-baseline/README.md) | sinkhole, Windows, auditd, FIM e Wazuh | IN PROGRESS |
| 4 | Detection engineering | [`docs/04-detection-engineering`](docs/04-detection-engineering/README.md) | matrice TP/TN, tuning e metriche | IN PROGRESS |
| 5-10 | Sei campagne | [`labs`](labs/README.md) | un caso completo per campagna | BLOCKED |
| 11 | Reporting | [`docs/05-reporting`](docs/05-reporting/README.md) | finding, IR report e timeline UTC | NOT STARTED |
| 12 | Pubblicazione | [`docs/06-publication`](docs/06-publication/README.md) | evidenze sanificate e release checklist | NOT STARTED |

## Metodo di lavoro per ogni caso

1. Leggere e citare le fonti.
2. Separare osservato, derivato e ipotizzato.
3. Definire emulazione sicura, test positivo, test negativo, kill switch e cleanup.
4. Eseguire da snapshot `LOGGING-READY`.
5. Raccogliere telemetria e costruire una timeline UTC.
6. Scrivere e testare la detection.
7. Eseguire cleanup e verificare la baseline.
8. Redigere finding e scheda IR.
9. Sanificare le evidenze.
10. Pubblicare tramite pull request con checklist completa.

## Regola di pubblicazione

Il repository contiene soltanto materiale **PUBLIC** o **SANITIZED**. Non caricare mai credenziali, token, dati reali, identificatori dell'host, log completi non revisionati, immagini disco, malware o payload operativi. Le evidenze raw restano nello storage privato; [`evidence`](evidence/README.md) ospita solo copie pubblicabili e ridotte.

## Struttura

```text
.
├── docs/        metodo, ambiente, telemetria, detection, reporting, pubblicazione
├── labs/        percorso ambiente + sei campagne
├── templates/   modelli riutilizzabili per ogni caso
├── evidence/    sole evidenze sanificate e manifest pubblici
├── configs/     configurazioni didattiche validate e senza segreti
├── scripts/     script benigni, cleanup e raccolta controllata
├── sources/     indice delle fonti e note di attribuzione
└── .github/     template per issue e pull request
```

## Stati di avanzamento

- `NOT STARTED`: attività non iniziata.
- `NEXT`: prossimo componente pianificato.
- `IN PROGRESS`: attività avviata; possono esistere checkpoint ed evidenze parziali.
- `BLOCKED`: attività intenzionalmente non eseguibile finché un gate precedente non è completato.
- `VALIDATED`: Definition of Done della fase completata con verifiche ripetibili.
- `SANITIZED`: copia pubblica revisionata per privacy e sicurezza.
- `PUBLISHED`: caso completo pubblicato con evidenze, hash, fonti e limiti dichiarati.

## Licenza

Nessuna licenza è ancora stata scelta. Fino all'aggiunta di un file `LICENSE`, il contenuto rimane protetto dal diritto d'autore e non concede automaticamente diritti di riutilizzo.
