# Evidenze pubbliche

Questa cartella ospita esclusivamente copie `SANITIZED` o documentazione `PUBLIC`. Le acquisizioni raw, gli output completi e i metadati locali restano nello storage privato esterno al repository.

## Checkpoint pubblicati

| Exercise ID | Fase | Evidenza | Esito | Data UTC |
|---|---|---|---|---|
| `ENV-2026-03` | STEP-02 | [`sanitized/ENV-2026-03-sinkhole-baseline.md`](sanitized/ENV-2026-03-sinkhole-baseline.md) | PASS | 2026-08-03 |
| `ENV-2026-04` | STEP-04 parziale | [`sanitized/ENV-2026-04-sinkhole-ready.md`](sanitized/ENV-2026-04-sinkhole-ready.md) | PASS | 2026-08-03 |
| `ENV-2026-05` | STEP-03/04 parziale | [`sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`](sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md) | PASS | 2026-08-04 |
| `ENV-2026-06` | STEP-02/03/04 parziale | [`sanitized/ENV-2026-06-multisource-telemetry-ready.md`](sanitized/ENV-2026-06-multisource-telemetry-ready.md) | PASS parziale | 2026-08-05 |

## Ambito dei checkpoint

- `ENV-2026-03`: baseline isolata e snapshot `CLEAN-OS` di SINKHOLE-LAB.
- `ENV-2026-04`: servizio HTTP benigno, test 200/404/405, JSONL, rotazione, health check e snapshot `SINKHOLE-READY`.
- `ENV-2026-05`: WAZUH-LAB, agent Linux, acquisizione JSONL, regole `100101`–`100103`, isolamento e snapshot `WAZUH-PIPELINE-READY`.
- `ENV-2026-06`: WIN11-LAB, Sysmon, PowerShell 4104, Task Scheduler, auditing 4698/4699, dataset sintetico, NTP interno, smoke test NAT-less e snapshot `*-TELEMETRY-READY` dei tre nodi.

`ENV-2026-06` non equivale a `LOGGING-READY`: APPLIANCE-LAB, auditd/FIM, retention finale, metriche e ripetizione completa dopo rollback restano aperti.

## Convenzione

Per checkpoint di ambiente:

```text
evidence/sanitized/<EXERCISE-ID>-<descrizione>.md
```

Per casi completi:

```text
evidence/sanitized/<CASE-ID>/
├── manifest.csv
├── E-001-endpoint-events.csv
├── E-002-process-tree.csv
├── E-002-process-tree.png
├── E-003-artifacts.csv
├── E-004-network.jsonl
├── E-005-alert.json
└── E-006-cleanup.md
```

Le directory `evidence/private`, `evidence/raw` ed `evidence/staging` sono escluse da Git. Lo storage privato principale deve comunque trovarsi fuori dalla directory del repository.

## Requisiti minimi di un'evidenza pubblica

Ogni artefatto deve dichiarare:

- Exercise ID o Case ID;
- classificazione;
- data e timestamp UTC;
- obiettivo e ambito;
- trasformazioni di sanificazione applicate;
- test eseguiti e risultato;
- limiti dell'evidenza;
- riferimento alla configurazione che ha prodotto il test;
- SHA-256 quando viene pubblicato un file derivato stabile.

## Gestione delle acquisizioni private

Per i checkpoint recenti sono stati usati pacchetti privati con manifesti SHA-256, verificati prima e dopo il trasferimento. Il repository pubblico registra soltanto l'esito e le informazioni necessarie a riprodurre il controllo, non:

- inventari completi di processi, servizi e task;
- EVTX, PCAP, immagini disco o snapshot;
- UUID, MAC address o percorsi locali dell'host;
- credenziali, token, chiavi agent o certificati privati;
- log completi e archivi raw;
- hash di archivi privati non distribuiti.

## Contenuti vietati

Non pubblicare:

- immagini disco, ISO, snapshot o dump di memoria;
- EVTX, ETL, PCAP o log raw non revisionati;
- credenziali, token, cookie, chiavi o segreti;
- UUID, MAC address e percorsi riconducibili all'host personale;
- dati di persone, clienti, aziende, tenant o account reali;
- malware, exploit o payload operativi.

## Manifest minimo

Per ogni file pubblico registrare Evidence ID, classificazione, timestamp UTC, SHA-256, fonte, trasformazioni applicate e reviewer.

## Prossime evidenze pianificate

- baseline `CLEAN-OS` e telemetria di APPLIANCE-LAB;
- auditd e Wazuh FIM;
- retention finale;
- matrice TP/TN e metriche;
- ripetizione dopo rollback;
- snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.
