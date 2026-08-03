# 04 - Detection engineering

**Stato:** `BLOCKED`  
**Dipendenza:** Wazuh, agent e snapshot `LOGGING-READY`  
**Dato già disponibile:** schema JSONL del sinkhole validato in `ENV-2026-04`

Nessuna regola di detection viene dichiarata validata finché l'evento non è acquisito da Wazuh, testato con casi positivi e negativi e ripetuto dopo rollback.

## Stato delle fonti

| Fonte | Stato per detection |
|---|---|
| Sinkhole JSONL | sorgente pronta, ingestione Wazuh non ancora validata |
| Sysmon | non disponibile |
| PowerShell 4104 | non disponibile |
| Security 4698/4699 | non disponibile |
| auditd | non disponibile |
| Wazuh FIM | non disponibile |

Il checkpoint `SINKHOLE-READY` dimostra la generazione controllata degli eventi HTTP, non una detection.

## Candidati futuri dal sinkhole

Dopo l'ingestione in Wazuh potranno essere valutate regole come:

| Condizione | Significato difensivo iniziale | Rischio di falso positivo |
|---|---|---|
| `status = 200` e `path = /heartbeat` | heartbeat LAB riuscito | basso, ma non dimostra intento |
| `status = 405` | metodo non consentito | test amministrativi e scanner benigni |
| molti `404` dallo stesso client | enumerazione di percorsi | browser, typo e test automatici |
| frequenza elevata dallo stesso client | burst anomalo o loop | health check troppo frequente |

Questi sono casi d'uso pianificati, non regole validate.

## Workflow per ogni regola

1. Eseguire il comportamento positivo e conservare l'evento raw in storage privato.
2. Verificare che il parser esponga campi stabili.
3. Scrivere la regola usando campi strutturati, non il messaggio completo quando evitabile.
4. Testare Rule ID, level, description e MITRE.
5. Eseguire TP2 con nome, path o IP cambiato ma stessa tecnica.
6. Eseguire TN1 amministrativo.
7. Eseguire TN2 su host role legittimo.
8. Aggiungere contesto, non esclusioni globali.
9. Misurare il risultato.
10. Ripetere dopo rollback e verificare cleanup.

## Matrice minima

| Test | Esito atteso |
|---|---|
| TP1 comportamento esatto | alert con campi corretti |
| TP2 variante | alert ancora presente |
| TN1 amministrativo | nessun alert high o alert contestualizzato |
| TN2 host role | severity ridotta o allowlist condizionata |
| Resilienza | cambio hash/nome non rompe la regola |
| Cleanup | nessun processo o artefatto residuo |
| Rollback | stesso risultato dalla baseline ripristinata |

## Metriche

- detection latency;
- triage latency;
- coverage della catena;
- precision;
- data quality;
- repeatability;
- cleanup completeness.

## Gate di sblocco

La fase può passare da `BLOCKED` a `IN PROGRESS` quando:

- WAZUH-LAB è operativo e isolato;
- il JSONL del sinkhole è acquisito e decodificato;
- almeno un evento 200, uno 404 e uno 405 sono ricercabili per campi;
- timestamp e client IP sono conservati correttamente;
- esiste una procedura di test e cleanup.

Riferimenti:

- [`../03-telemetry-baseline/README.md`](../03-telemetry-baseline/README.md)
- [`../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md`](../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md)
- [`../../templates/detection-test.md`](../../templates/detection-test.md)
