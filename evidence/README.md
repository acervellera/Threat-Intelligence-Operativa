# Evidenze pubbliche

Questa cartella ospita esclusivamente copie `SANITIZED` o documentazione `PUBLIC`. Le acquisizioni raw, gli output completi e i metadati locali restano nello storage privato esterno al repository.

## Stato corrente

Primo checkpoint pubblicato:

| Exercise ID | Fase | Evidenza | Esito | Data UTC |
|---|---|---|---|---|
| `ENV-2026-03` | STEP-02 | [`sanitized/ENV-2026-03-sinkhole-baseline.md`](sanitized/ENV-2026-03-sinkhole-baseline.md) | PASS | 2026-08-03 |

Il documento descrive la baseline isolata di `SINKHOLE-LAB` senza pubblicare UUID, MAC address, percorsi dell'host, immagini disco, ISO o log completi.

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
- SHA-256 quando viene pubblicato un file derivato.

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
