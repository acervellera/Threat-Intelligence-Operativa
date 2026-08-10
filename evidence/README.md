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
| `ENV-2026-08` | STEP-03/04 | [`sanitized/ENV-2026-08-retention-baseline.md`](sanitized/ENV-2026-08-retention-baseline.md) | PASS | 2026-08-07 |
| `ENV-2026-09` | STEP-04 | [`sanitized/ENV-2026-09-formal-tp-tn-matrix.md`](sanitized/ENV-2026-09-formal-tp-tn-matrix.md) | PASS | 2026-08-07 |
| `ENV-2026-10` | STEP-11 | [`sanitized/ENV-2026-10-detection-metrics.md`](sanitized/ENV-2026-10-detection-metrics.md) | PASS | 2026-08-07 |
| `ENV-2026-11` | STEP-02/04/11 | [`sanitized/ENV-2026-11-rollback-repeatability.md`](sanitized/ENV-2026-11-rollback-repeatability.md) | PASS | 2026-08-07 |
| `ENV-2026-12` | STEP-02/03/04 | [`sanitized/ENV-2026-12-cleanup-baseline.md`](sanitized/ENV-2026-12-cleanup-baseline.md) | PASS | 2026-08-10 |
| `ENV-2026-13` | STEP-02/03/04 | [`sanitized/ENV-2026-13-logging-ready.md`](sanitized/ENV-2026-13-logging-ready.md) | PASS | 2026-08-10 |

## Ambito dei checkpoint

- `ENV-2026-03`: baseline isolata e snapshot `CLEAN-OS` di SINKHOLE-LAB.
- `ENV-2026-04`: HTTP benigno, test 200/404/405, JSONL, rotazione, health check e `SINKHOLE-READY`.
- `ENV-2026-05`: WAZUH-LAB, agent Linux, acquisizione JSONL, regole `100101`–`100103`, isolamento e `WAZUH-PIPELINE-READY`.
- `ENV-2026-06`: WIN11-LAB, Sysmon, PowerShell 4104, Task Scheduler, Security 4698/4699, dataset sintetico, NTP interno e smoke test NAT-less.
- `ENV-2026-07`: APPLIANCE-LAB, auditd, raccolta Audit, rule `80789`, FIM Whodata rules `550/553/554`, recovery SCA, isolamento e `APPLIANCE-TELEMETRY-READY`.
- `ENV-2026-08`: retention finale per Wazuh, sinkhole, auditd e Windows Event Log.
- `ENV-2026-09`: matrice formale multi-nodo con 8 TP, 6 TN e 14/14 PASS; cleanup FIM verificato separatamente.
- `ENV-2026-10`: metriche del set controllato: scenario completion, TP/TN, precisione alert, latenza osservabile e completezza dei campi.
- `ENV-2026-11`: baseline coordinata, rollback reale e repeatability 8/8 sul set rappresentativo multi-pipeline.
- `ENV-2026-12`: cleanup globale dei residui operativi del test harness e health check finale dei quattro nodi.
- `ENV-2026-13`: inventario finale e snapshot `LOGGING-READY` / `LOGGING-READY-LINUX`; gate Track A PASS.

`ENV-2026-13` chiude il gate infrastrutturale `LOGGING-READY`. Il primo caso Track A può iniziare dalla baseline finale verificata.

## Visualizzazioni

Le visualizzazioni sanificate derivate da `ENV-2026-10/11` sono disponibili in:

```text
evidence/sanitized/visualizations/ENV-2026-10-11/
```

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

I checkpoint usano pacchetti privati con manifesti SHA-256 verificati prima e dopo il trasferimento. I checkpoint finali conservano dataset, riepiloghi, inventari o visualizzazioni congelati con manifesti verificati. Il repository pubblico registra soltanto l'esito e le informazioni necessarie a riprodurre il controllo, non:

- inventari completi di processi, servizi e task;
- EVTX, PCAP, immagini disco o snapshot;
- UUID, MAC address o percorsi locali dell'host;
- credenziali, token, chiavi agent o certificati privati;
- log completi e archivi raw;
- hash di archivi privati non distribuiti.

## Contenuti vietati

Non pubblicare immagini disco, ISO, snapshot, dump di memoria, log raw non revisionati, credenziali, token, cookie, chiavi, dati reali, identificatori dell'host, malware, exploit o payload operativi.

## Prossima evidenza pianificata

- `CASE-01 — CaptiveCrunch / Storm-2945`, Track A, emulazione benigna end-to-end dalla baseline `LOGGING-READY`.
