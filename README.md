# Threat Intelligence Operativa

Percorso pubblico e progressivo per trasformare fonti di threat intelligence in laboratori difensivi ripetibili, telemetria, detection engineering, evidenze verificabili e reporting professionale.

> Il repository riproduce comportamenti osservabili e post-condizioni, non malware, exploit operativi o furto di credenziali. Tutte le attività devono avvenire in VM isolate, con dati sintetici, snapshot e destinazioni di rete interne.

## Stato corrente

**Fase primaria attiva:** `STEP-02 — Rete e VM`  
**Attività parallele:** `STEP-03 — Baseline telemetria` e `STEP-04 — Smoke test`  
**Checkpoint più recente:** `ENV-2026-05 — pipeline Wazuh ↔ sinkhole`  
**Pipeline Linux/JSONL:** `VALIDATED`  
**Snapshot finale LOGGING-READY:** `NOT READY`  
**Data:** `2026-08-04 UTC`

Completato e verificato:

- hypervisor KVM/QEMU con libvirt;
- rete host-only `lab-lan` su `10.10.10.0/24`, senza forwarding;
- `SINKHOLE-LAB` su Debian 13 con IP statico `10.10.10.30/24`;
- servizio HTTP `tio-sinkhole` su `10.10.10.30:8080`;
- endpoint benigno `GET/HEAD /heartbeat` e test HTTP 200/404/405;
- logging JSONL, rotazione giornaliera e retention di 14 archivi;
- health check sinkhole: `16 PASS`, `0 FAIL`;
- snapshot sinkhole `CLEAN-OS` e `SINKHOLE-READY`;
- `WAZUH-LAB` su Ubuntu Server 24.04 LTS, IP `10.10.10.40/24`;
- filesystem root WAZUH-LAB esteso a circa 77 GiB;
- Wazuh manager, indexer, dashboard e Filebeat attivi e abilitati;
- cluster indexer `green`, un nodo, zero shard non assegnati;
- snapshot WAZUH-LAB `CLEAN-OS` e `WAZUH-READY`;
- Wazuh Agent installato su SINKHOLE-LAB e collegato tramite `lab-lan`;
- NAT rimosso da SINKHOLE-LAB dopo l'installazione dell'agent;
- acquisizione di `/var/log/tio-sinkhole/requests.jsonl` tramite `wazuh-logcollector`;
- parsing JSON e label `@source=tio-sinkhole`, `lab.role=sinkhole`;
- regole custom validate per heartbeat 200, risposta 404 e risposta 405;
- alert verificati nel manager, nell'indexer e nel Threat Hunting del dashboard.

Riferimenti:

- [baseline isolata CLEAN-OS del sinkhole](evidence/sanitized/ENV-2026-03-sinkhole-baseline.md);
- [checkpoint SINKHOLE-READY](evidence/sanitized/ENV-2026-04-sinkhole-ready.md);
- [pipeline Wazuh ↔ sinkhole](evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md);
- [configurazione sanificata della rete](configs/libvirt/lab-lan.sanitized.xml);
- [servizio sinkhole e guida di installazione](configs/sinkhole/README.md);
- [configurazioni Wazuh validate](configs/wazuh/README.md);
- [baseline di telemetria](docs/03-telemetry-baseline/README.md);
- [detection engineering](docs/04-detection-engineering/README.md);
- [stato complessivo](PROGRESS.md);
- [roadmap aggiornata](ROADMAP.md);
- Issue `#3 — Costruire rete host-only e macchine virtuali`;
- Issue `#5 — Dataset sintetico, sinkhole e snapshot LOGGING-READY`.

**Prossimo checkpoint operativo:** rimuovere la NAT temporanea da `WAZUH-LAB`, verificare egress deny e funzionamento della pipeline in isolamento; successivamente creare `WIN11-LAB` su `10.10.10.20`.

## Obiettivo

Completare il percorso dall'allestimento del laboratorio fino alla pubblicazione di sei casi documentati:

1. CaptiveCrunch / Storm-2945
2. ACR Stealer - Chain A e Chain B
3. UNC1069 - fake meeting e browser extension
4. UNC3753 / Luna Moth - vishing, RMM e data theft
5. BRICKSTORM - appliance Linux/vSphere
6. WinRAR CVE-2025-8088 - ADS e Startup persistence

Ogni caso deve produrre:

- brief della campagna;
- catena temporale e mapping MITRE ATT&CK con confidence A/B/C;
- runbook ripetibile;
- telemetria e registro evidenze E-001...E-006;
- regola Wazuh, test positivo, test negativo e tuning;
- finding da penetration test;
- scheda incident response;
- cleanup verificato;
- pacchetto pubblico anonimizzato.

## Inizia qui

| Ordine | Fase | Cartella | Uscita richiesta | Stato corrente |
|---:|---|---|---|---|
| 0 | Governance e sicurezza | [`docs/00-governance`](docs/00-governance/README.md) | Regole PUBLIC/SANITIZED/PRIVATE | IN PROGRESS |
| 1 | Metodo analitico | [`docs/01-method`](docs/01-method/README.md) | Scheda A/B/C e catena neutra | NOT STARTED |
| 2 | Costruzione ambiente | [`labs/00-environment`](labs/00-environment/README.md) | Topologia, snapshot e health check | IN PROGRESS |
| 3 | Baseline telemetria | [`docs/03-telemetry-baseline`](docs/03-telemetry-baseline/README.md) | Sinkhole, Sysmon, PowerShell, auditd e Wazuh | IN PROGRESS; pipeline Linux/JSONL validata |
| 4 | Detection engineering | [`docs/04-detection-engineering`](docs/04-detection-engineering/README.md) | Matrice TP/TN, tuning e metriche | IN PROGRESS; prime regole tecniche validate |
| 5-10 | Sei campagne | [`labs`](labs/README.md) | Un caso completo per campagna | BLOCKED |
| 11 | Reporting | [`docs/05-reporting`](docs/05-reporting/README.md) | Finding, IR report e timeline UTC | NOT STARTED |
| 12 | Pubblicazione | [`docs/06-publication`](docs/06-publication/README.md) | Evidenze sanificate e release checklist | NOT STARTED |

Il piano operativo completo è in [`ROADMAP.md`](ROADMAP.md). Lo stato di avanzamento è in [`PROGRESS.md`](PROGRESS.md).

## Topologia prevista

| Nodo | Indirizzo | Ruolo | Stato |
|---|---|---|---|
| Host Ubuntu / bridge libvirt | `10.10.10.1` | Gestione locale della rete LAB | VALIDATED |
| WIN11-LAB | `10.10.10.20` | Sysmon, PowerShell logging, Wazuh agent | NEXT |
| SINKHOLE-LAB | `10.10.10.30` | HTTP interno, heartbeat e log JSONL | SINKHOLE-READY; agent Active |
| WAZUH-LAB | `10.10.10.40` | Manager, indexer e dashboard | PIPELINE VALIDATED; NAT temporanea presente |
| APPLIANCE-LAB | `10.10.10.50` | auditd, FIM e BRICKSTORM | NOT STARTED |
| ANALYST-LAB | `10.10.10.60` | Analisi e reporting, opzionale | NOT STARTED |

La rete LAB è priva di forwarding. Le interfacce NAT sono ammesse solo durante installazione e aggiornamento e devono essere rimosse prima dei test di campagna.

## Checkpoint disponibili

| Exercise ID | Snapshot / ambito | Esito |
|---|---|---|
| `ENV-2026-03` | `CLEAN-OS` SINKHOLE-LAB | PASS |
| `ENV-2026-04` | `SINKHOLE-READY` | PASS |
| `ENV-2026-05` | pipeline Wazuh Agent → Manager → Indexer → Dashboard | PASS parziale; non è LOGGING-READY |

Gli snapshot interni QCOW2 non sostituiscono un backup indipendente. Lo snapshot `WAZUH-READY` è precedente alla configurazione finale della pipeline JSONL e delle regole custom.

## Regola di pubblicazione

Il repository contiene soltanto materiale **PUBLIC** o **SANITIZED**. Non caricare mai:

- credenziali, cookie, token, wallet, account o documenti reali;
- nomi di persone, clienti, aziende o host interni;
- IP, domini, tenant, e-mail e percorsi riconducibili a un ambiente reale;
- EVTX, PCAP, memory dump o immagini disco non sanificati;
- malware, exploit, archivi weaponized o payload operativi;
- log completi prima della revisione e anonimizzazione.

Le evidenze raw restano fuori dal repository in uno storage privato. La cartella [`evidence`](evidence/README.md) ospita solo copie pubblicabili e ridotte.

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
- `NEXT`: prossimo componente pianificato nella fase corrente.
- `IN PROGRESS`: attività avviata; possono esistere checkpoint ed evidenze parziali.
- `BLOCKED`: attività intenzionalmente non eseguibile finché un gate precedente non è completato.
- `VALIDATED`: Definition of Done della fase completata con verifiche ripetibili.
- `SANITIZED`: copia pubblica revisionata per privacy e sicurezza.
- `PUBLISHED`: caso completo pubblicato con hash, fonti e limiti dichiarati.

## Metodo di lavoro per ogni caso

1. Leggere e citare le fonti.
2. Separare osservato, derivato e ipotizzato.
3. Definire emulazione sicura, test positivo, test negativo, kill switch e cleanup.
4. Eseguire da snapshot `LOGGING-READY`.
5. Raccogliere telemetria e costruire timeline UTC.
6. Scrivere e testare la detection.
7. Eseguire cleanup e verificare la baseline.
8. Redigere finding e scheda IR.
9. Sanificare le evidenze.
10. Pubblicare tramite pull request con checklist completa.

## Licenza

Nessuna licenza è ancora stata scelta. Fino all'aggiunta di un file `LICENSE`, il contenuto rimane protetto dal diritto d'autore e non concede automaticamente diritti di riutilizzo.
