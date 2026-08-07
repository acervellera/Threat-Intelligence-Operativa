# ENV-2026-11 — Rollback coordinato e ripetibilità

**Classificazione:** SANITIZED  
**Data UTC:** 2026-08-07  
**Esito:** PASS

## Obiettivo

Verificare che il laboratorio Track A torni a uno stato noto dopo un vero rollback coordinato e che un set rappresentativo di test TP/TN mantenga lo stesso esito prima e dopo il ripristino.

## Baseline

È stata creata una baseline coordinata denominata `ENV-2026-11-BASELINE` sui quattro nodi principali con le VM spente. La baseline includeva la configurazione di telemetria e retention già validata nei checkpoint precedenti.

## Metodo

Il checkpoint ha usato un set rappresentativo di otto scenari:

| Pipeline | TP | TN |
|---|---|---|
| Sinkhole | 404 target | heartbeat non target |
| Windows | PowerShell marker | PowerShell benigno senza trigger |
| Audit Linux | esecuzione sorvegliata | comando esterno al watch target |
| FIM Linux | creazione in path monitorato | creazione fuori dal path monitorato |

La sequenza è stata:

1. creazione della baseline a VM spente;
2. avvio coordinato e health check;
3. `RUN-1` del set rappresentativo;
4. shutdown pulito dei quattro nodi;
5. `snapshot-revert` reale verso `ENV-2026-11-BASELINE`;
6. verifica che gli artefatti del `RUN-1` non fossero più presenti;
7. verifica che il Wazuh manager ripristinato non contenesse gli alert del `RUN-1`;
8. riavvio coordinato;
9. `RUN-2` dello stesso set rappresentativo;
10. confronto degli esiti validi.

## Risultati

| Controllo | Risultato |
|---|---:|
| VM ripristinate alla baseline | 4/4 |
| Artefatti `RUN-1` verificati assenti dopo revert | 3/3 |
| Alert `RUN-1` presenti sul manager dopo revert | 0 |
| `RUN-1` | 8/8 PASS |
| `RUN-2` valido | 8/8 PASS |
| Coerenza degli scenari validi | 8/8 |
| Ripetibilità sul set rappresentativo | 100,00% |
| Rollback funzionale | PASS |

## Anomalie del test harness

Durante `RUN-2` sono stati identificati due tentativi non validi e conservati come finding metodologici.

Il primo tentativo Windows TP ha prodotto due Event ID 4104 distinti con lo stesso marker. La correlazione ha mostrato due eventi sorgente reali, quindi non si trattava di una duplicazione della pipeline Wazuh. Il tentativo è stato classificato `INVALID` per contaminazione del test harness.

Il primo retest Windows ha invece usato marker vuoti nella shell. Il verificatore avrebbe quindi confrontato la stringa vuota, che corrisponde a ogni riga, producendo conteggi non validi. Anche questo tentativo è stato classificato `INVALID` e non come fallimento della detection.

Un retest Windows con protezione esplicita contro marker vuoti ha prodotto 1 alert target per il TP e 0 per il TN, entrambi PASS.

## Interpretazione

Il risultato di ripetibilità del 100,00% si riferisce esclusivamente agli otto scenari rappresentativi validi usati nel checkpoint. Non significa che ogni possibile detection, configurazione o comportamento del laboratorio sia stato rieseguito dopo rollback.

Il checkpoint dimostra che:

- il revert riporta effettivamente i filesystem allo stato della baseline;
- il manager Wazuh torna allo stato precedente alla generazione degli alert `RUN-1`;
- le quattro pipeline rappresentative mantengono l'esito TP/TN dopo il ripristino;
- gli errori del test harness vengono distinti dai problemi della detection e conservati come evidenza metodologica.

## Sanificazione

Non sono pubblicati marker completi, timestamp di singoli eventi, Record ID, ScriptBlock ID, percorsi host privati, log raw, hash privati, credenziali o metadati di virtualizzazione non necessari alla riproducibilità.

I risultati completi, gli script di verifica e il manifesto SHA-256 rimangono nello storage privato.