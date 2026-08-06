# Evidenze pubbliche

Questa cartella ospita esclusivamente copie `SANITIZED` o documentazione `PUBLIC`. Le acquisizioni raw, gli output completi e i metadati locali restano nello storage privato esterno al repository.

## Checkpoint pubblicati

| Exercise ID | Fase | Evidenza | Esito | Data UTC |
|---|---|---|---|---|
| `ENV-2026-03` | STEP-02 | [`sanitized/ENV-2026-03-sinkhole-baseline.md`](sanitized/ENV-2026-03-sinkhole-baseline.md) | PASS | 2026-08-03 |
| `ENV-2026-04` | STEP-04 parziale | [`sanitized/ENV-2026-04-sinkhole-ready.md`](sanitized/ENV-2026-04-sinkhole-ready.md) | PASS | 2026-08-03 |
| `ENV-2026-05` | STEP-03/04 parziale | [`sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`](sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md) | PASS | 2026-08-04 |
| `ENV-2026-06` | STEP-02/03/04 parziale | [`sanitized/ENV-2026-06-multisource-telemetry-ready.md`](sanitized/ENV-2026-06-multisource-telemetry-ready.md) | PASS parziale | 2026-08-05 |
| `ENV-2026-07` | STEP-02/03/04 parziale | [`sanitized/ENV-2026-07-appliance-telemetry-ready.md`](sanitized/ENV-2026-07-appliance-telemetry-ready.md) | PASS parziale | 2026-08-06 |

## Ambito dei checkpoint

- `ENV-2026-03`: baseline isolata e snapshot `CLEAN-OS` di SINKHOLE-LAB.
- `ENV-2026-04`: HTTP benigno, test 200/404/405, JSONL, rotazione, health check e `SINKHOLE-READY`.
- `ENV-2026-05`: WAZUH-LAB, agent Linux, acquisizione JSONL, regole `100101`–`100103`, isolamento e `WAZUH-PIPELINE-READY`.
- `ENV-2026-06`: WIN11-LAB, Sysmon, PowerShell 4104, Task Scheduler, Security 4698/4699, dataset sintetico, NTP interno e smoke test NAT-less.
- `ENV-2026-07`: APPLIANCE-LAB, auditd, raccolta Audit, rule `80789`, FIM Whodata rules `550/553/554`, recovery SCA, isolamento e `APPLIANCE-TELEMETRY-READY`.

`ENV-2026-07` non equivale a `LOGGING-READY`: retention finale, matrice TP/TN, metriche e ripetizione coordinata dopo rollback restano aperte.

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

I checkpoint usano pacchetti privati con manifesti SHA-256 verificati prima e dopo il trasferimento. Il repository pubblico registra soltanto l'esito e le informazioni necessarie a riprodurre il controllo, non:

- inventari completi di processi, servizi e task;
- EVTX, PCAP, immagini disco o snapshot;
- UUID, MAC address o percorsi locali dell'host;
- credenziali, token, chiavi agent o certificati privati;
- log completi e archivi raw;
- hash di archivi privati non distribuiti.

## Contenuti vietati

Non pubblicare immagini disco, ISO, snapshot, dump di memoria, log raw non revisionati, credenziali, token, cookie, chiavi, dati reali, identificatori dell'host, malware, exploit o payload operativi.

## Prossime evidenze pianificate

- retention finale;
- matrice TP/TN e metriche;
- smoke test coordinato dei quattro nodi;
- ripetizione dopo rollback;
- snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.
