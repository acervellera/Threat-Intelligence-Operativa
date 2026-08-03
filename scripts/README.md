# Script

Gli script pubblici devono essere benigni, leggibili e limitati al laboratorio.

## Script disponibili

| File | Scopo | Stato | Evidenza |
|---|---|---|---|
| [`common/tio-sinkhole-check.sh`](common/tio-sinkhole-check.sh) | health check del servizio HTTP, rete e logrotate | VALIDATED | `ENV-2026-04` |

Il health check esegue 16 controlli e genera soltanto tre richieste HTTP controllate:

```text
GET  /heartbeat              -> 200
GET  /percorso-inesistente   -> 404
POST /heartbeat              -> 405
```

Risultato validato:

```text
Controlli superati: 16
Controlli falliti: 0
RISULTATO: PASS
```

## Struttura

```text
scripts/
├── common/
├── campaign-01-captivecrunch/
├── campaign-02-acr-stealer/
├── campaign-03-unc1069/
├── campaign-04-unc3753/
├── campaign-05-brickstorm/
└── campaign-06-winrar/
```

## Requisiti

Ogni script deve avere:

- intestazione `LAB ONLY`;
- prerequisiti;
- input espliciti;
- destinazioni interne;
- nessun segreto;
- kill switch o condizione di arresto;
- cleanup corrispondente quando crea artefatti persistenti;
- side effect dichiarati;
- output e codici di uscita documentati;
- test positivo e negativo quando applicabili.

## Regole per gli health check

Uno script di verifica deve:

- evitare modifiche permanenti alla configurazione;
- eseguire tutti i controlli anche quando uno fallisce;
- distinguere chiaramente `PASS` e `FAIL`;
- restituire codice `0` soltanto quando tutti i controlli superano il test;
- eliminare i file temporanei;
- dichiarare gli eventi controllati che genera;
- essere eseguibile dopo riavvio e rollback.

## Prossimi script pianificati

- health check di WAZUH-LAB;
- test di parsing JSONL del sinkhole;
- verifica connettività tra agent e manager;
- smoke test end-to-end;
- cleanup dei marker sintetici.
