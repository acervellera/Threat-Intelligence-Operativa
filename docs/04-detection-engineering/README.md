# 04 - Detection engineering

## Workflow per ogni regola

1. Eseguire il comportamento positivo e conservare l'evento raw in storage privato.
2. Scrivere la regola con campi stabili: image, parentImage, commandLine, targetFilename, targetObject.
3. Testare Rule ID, level, description e MITRE.
4. Eseguire TP2 con nome, path o IP cambiato ma stessa tecnica.
5. Eseguire TN1 amministrativo.
6. Eseguire TN2 su host role legittimo.
7. Aggiungere contesto, non esclusioni globali.
8. Misurare il risultato.

## Matrice minima

| Test | Esito atteso |
|---|---|
| TP1 comportamento esatto | alert con campi corretti |
| TP2 variante | alert ancora presente |
| TN1 amministrativo | nessun alert high o alert contestualizzato |
| TN2 host role | severity ridotta o allowlist condizionata |
| Resilienza | cambio hash/nome non rompe la regola |
| Cleanup | nessun processo o artefatto residuo |

## Metriche

- detection latency;
- triage latency;
- coverage della catena;
- precision;
- data quality;
- repeatability;
- cleanup completeness.

Usare [`templates/detection-test.md`](../../templates/detection-test.md).
