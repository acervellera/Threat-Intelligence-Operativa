# Threat Intelligence Operativa

Percorso pubblico e progressivo per trasformare fonti di threat intelligence in laboratori difensivi ripetibili, telemetria, detection engineering, evidenze verificabili e reporting professionale.

> Il repository riproduce comportamenti osservabili e post-condizioni, non malware, exploit operativi o furto di credenziali. Tutte le attività devono avvenire in VM isolate, con dati sintetici, snapshot e destinazioni di rete interne.

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

| Ordine | Fase | Cartella | Uscita richiesta |
|---:|---|---|---|
| 0 | Governance e sicurezza | [`docs/00-governance`](docs/00-governance/README.md) | Regole PUBLIC/SANITIZED/PRIVATE |
| 1 | Metodo analitico | [`docs/01-method`](docs/01-method/README.md) | Scheda A/B/C e catena neutra |
| 2 | Costruzione ambiente | [`labs/00-environment`](labs/00-environment/README.md) | Topologia, snapshot e health check |
| 3 | Baseline telemetria | [`docs/03-telemetry-baseline`](docs/03-telemetry-baseline/README.md) | Sysmon, PowerShell, auditd e Wazuh validati |
| 4 | Detection engineering | [`docs/04-detection-engineering`](docs/04-detection-engineering/README.md) | Matrice TP/TN, tuning e metriche |
| 5-10 | Sei campagne | [`labs`](labs/README.md) | Un caso completo per campagna |
| 11 | Reporting | [`docs/05-reporting`](docs/05-reporting/README.md) | Finding, IR report e timeline UTC |
| 12 | Pubblicazione | [`docs/06-publication`](docs/06-publication/README.md) | Evidenze sanificate e release checklist |

Il piano operativo completo è in [`ROADMAP.md`](ROADMAP.md). Lo stato di avanzamento è in [`PROGRESS.md`](PROGRESS.md).

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

- `NOT STARTED`: non iniziato.
- `IN PROGRESS`: attività in corso, nessuna evidenza pubblicata.
- `VALIDATED`: test positivo, test negativo e cleanup completati.
- `SANITIZED`: revisione privacy e sicurezza completata.
- `PUBLISHED`: caso pubblicato con hash e fonti.

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
