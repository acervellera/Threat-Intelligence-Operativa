# 04 - Detection engineering

**Stato:** `IN PROGRESS`  
**Checkpoint:** `ENV-2026-05 — pipeline Wazuh ↔ sinkhole`  
**Ambito validato:** prime regole tecniche su telemetria HTTP JSONL

La fase non è ancora `VALIDATED`: le regole 200/404/405 dimostrano la pipeline, ma mancano test negativi formali, tuning, metriche e ripetizione dopo rollback.

## Stato delle fonti

| Fonte | Stato per detection |
|---|---|
| Sinkhole JSONL | VALIDATED per pipeline e campi |
| Wazuh manager/indexer/dashboard | VALIDATED per pipeline Linux |
| Sysmon | non disponibile |
| PowerShell 4104 | non disponibile |
| Security 4698/4699 | non disponibile |
| auditd | non disponibile |
| Wazuh FIM | non disponibile |

## Regole validate nel checkpoint tecnico

File pubblico:

- [`../../configs/wazuh/rules/tio_sinkhole_rules.xml`](../../configs/wazuh/rules/tio_sinkhole_rules.xml)

| Rule ID | Livello | Condizione | Interpretazione |
|---:|---:|---|---|
| `100100` | 0 | JSON da `requests.jsonl` | regola padre, nessun alert |
| `100101` | 3 | status 200 e path `/heartbeat` | heartbeat LAB riuscito |
| `100102` | 5 | status 404 | percorso inesistente da osservare |
| `100103` | 7 | status 405 | metodo non consentito |

Un singolo 404 o 405 non è considerato prova di attività malevola. Queste regole hanno scopo didattico e di validazione della pipeline.

## Errore individuato e correzione

Il campo JSON `status` viene trattato dal motore Wazuh come campo statico. La forma seguente non è valida:

```xml
<field name="status">^404$</field>
```

La forma validata è:

```xml
<status type="pcre2">^404$</status>
```

La configurazione errata è stata rilevata da `wazuh-analysisd -t` prima del riavvio del manager; il servizio in esecuzione non è stato compromesso.

## Verifiche eseguite

- controllo preventivo di collisione degli ID;
- file con proprietario `root:wazuh` e permessi `0640`;
- validazione con `wazuh-analysisd -t`;
- test 200, 404 e 405 con `wazuh-logtest`;
- riavvio controllato del manager;
- verifica `wazuh-manager` e `filebeat` attivi;
- generazione di eventi reali con User-Agent riconoscibili;
- alert presenti in `alerts.json`;
- inoltro all'indexer;
- ricerca nel Threat Hunting del dashboard.

Query DQL usata nel campo **Search**:

```text
rule.id:100101 or rule.id:100102 or rule.id:100103
```

La query completa non deve essere inserita nel campo **Field** della finestra `Add filter`.

## Workflow per ogni regola futura

1. Eseguire il comportamento positivo e conservare l'evento raw in storage privato.
2. Verificare che il parser esponga campi stabili.
3. Scrivere la regola usando campi strutturati.
4. Validare sintassi e conflitti.
5. Testare Rule ID, level, description e MITRE.
6. Eseguire TP2 con una variante della stessa tecnica.
7. Eseguire TN1 amministrativo.
8. Eseguire TN2 su host role legittimo.
9. Aggiungere contesto, non esclusioni globali.
10. Misurare il risultato.
11. Ripetere dopo rollback e verificare cleanup.

## Matrice minima

| Test | Stato checkpoint sinkhole | Esito atteso finale |
|---|---|---|
| TP1 comportamento esatto | PASS | alert con campi corretti |
| TP2 variante | PARTIAL | alert ancora presente |
| TN1 amministrativo | NOT STARTED | nessun alert high o alert contestualizzato |
| TN2 host role | NOT STARTED | severity ridotta o allowlist condizionata |
| Resilienza | NOT STARTED | cambio hash/nome non rompe la regola |
| Cleanup | PARTIAL | nessun processo o artefatto residuo |
| Rollback | NOT STARTED | stesso risultato dalla baseline ripristinata |

## Tuning pianificato

| Caso | Miglioramento |
|---|---|
| 404 singolo | mantenere bassa severità o solo telemetria |
| burst di 404 | correlare frequenza, client e timeframe |
| 405 singolo | distinguere test amministrativi e scanner autorizzati |
| heartbeat | aggiungere exercise ID o User-Agent di test |
| host multipli | usare `agent.name`, ruolo e gruppo |
| campagne | correlare endpoint, rete, persistenza e identità |

## Metriche da raccogliere

- detection latency;
- triage latency;
- coverage della catena;
- precision;
- data quality;
- repeatability;
- cleanup completeness.

## Gate residuo

La fase può diventare `VALIDATED` soltanto dopo:

- rimozione della NAT da WAZUH-LAB e verifica in isolamento;
- test negativi formalizzati;
- tuning delle regole;
- misurazione delle metriche;
- ripetizione dopo rollback;
- telemetria Windows e appliance;
- snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

Riferimenti:

- [`../03-telemetry-baseline/README.md`](../03-telemetry-baseline/README.md)
- [`../../configs/wazuh/README.md`](../../configs/wazuh/README.md)
- [`../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`](../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md)
- [`../../templates/detection-test.md`](../../templates/detection-test.md)
