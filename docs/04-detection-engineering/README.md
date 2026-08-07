# 04 - Detection engineering

**Stato:** `IN PROGRESS`  
**Checkpoint:** `ENV-2026-09 — matrice formale TP/TN multi-nodo`  
**Matrice:** `8 TP + 6 TN = 14/14 PASS`  
**Ambito non ancora chiuso:** metriche formali, tuning, repeatability dopo rollback

## Stato delle fonti

| Fonte | Stato per detection |
|---|---|
| Sinkhole JSONL | VALIDATED |
| Wazuh Agent Linux sinkhole | VALIDATED |
| Wazuh manager/indexer/dashboard | VALIDATED per checkpoint |
| Sysmon | VALIDATED per baseline LAB |
| PowerShell 4104 | VALIDATED |
| Task Scheduler 106/141 | VALIDATED |
| Security 4698 | VALIDATED |
| Security 4699 | OBSERVED / DISCOVERY |
| auditd | VALIDATED |
| Wazuh FIM appliance | VALIDATED |

## Regole e mapping tecnici validati

| Rule ID | Fonte | Condizione LAB | Stato |
|---:|---|---|---|
| `100101` | sinkhole JSONL | heartbeat 200 | TP PASS |
| `100102` | sinkhole JSONL | status 404 | TP/TN PASS |
| `100103` | sinkhole JSONL | status 405 | TP/TN PASS |
| `109910` | PowerShell | Event 4104 con marker LAB | TP/TN PASS |
| `67014` | Task Scheduler | Event 106 task registrata | TP PASS |
| `60228` | Security | Event 4698 task creata | TP PASS |
| `67015` | Task Scheduler | Event 141 task eliminata | cleanup PASS |
| `80789` | auditd | execute watch `tio_appliance_exec` | TP/TN PASS |
| `554` | FIM | file added | TP PASS |
| `550` | FIM | integrity changed | TP PASS |
| `553` | FIM | file deleted | cleanup PASS |

## Matrice formale ENV-2026-09

| Test | Expected | Observed | Esito |
|---|---|---|---|
| WIN-TP1 | `4104 -> 109910` | evento intenzionale rilevato | PASS |
| WIN-TN1 | 4104 benigno, no `109910` | target count 0 | PASS |
| WIN-TP2 | `106 -> 67014`, `4698 -> 60228` | entrambi presenti | PASS |
| WIN-TN2 | nessuna detection Windows target | `109910/67014/67015/60228 = 0` | PASS |
| SINK-TP1 | 200 -> `100101` | target presente | PASS |
| SINK-TP2 | 404 -> `100102` | target presente | PASS |
| SINK-TP3 | 405 -> `100103` | target presente | PASS |
| SINK-TN1 | heartbeat non deve matchare 404 | `100102 = 0` | PASS |
| SINK-TN2 | heartbeat non deve matchare 405 | `100103 = 0` | PASS |
| AUDIT-TP1 | execute watch -> `80789` | target presente | PASS |
| AUDIT-TN1 | attività fuori watch | `80789 = 0` | PASS |
| FIM-TP1 | added -> `554` | target presente | PASS |
| FIM-TP2 | modified -> `550` | target presente | PASS |
| FIM-TN1 | file fuori path | target FIM count 0 | PASS |

Cleanup FIM: `deleted -> 553`, verificato separatamente.

## Finding: contaminazione del test harness PowerShell

Il primo TP PowerShell ha evidenziato che i comandi usati per verificare una detection possono essere registrati a loro volta da Script Block Logging. Se il codice diagnostico contiene letteralmente sia il trigger sia il RUN ID, può produrre nuovi Event ID 4104 e nuovi alert `109910`.

Metodo corretto:

1. identificare l'evento intenzionale con Record ID / ScriptBlock ID;
2. classificare separatamente gli alert prodotti dal test harness;
3. non inserire il trigger letterale nei comandi diagnostici successivi;
4. preservare gli artefatti di contaminazione come finding metodologico, non nasconderli.

## Discovery: Security 4699

La cancellazione di una Scheduled Task benigna ha generato localmente Security Event ID `4699`, ma non è stato osservato un alert Wazuh corrispondente in `alerts.json`.

Questo non è classificato come FAIL perché:

- `4699` era definito come osservazione/discovery, non criterio obbligatorio;
- `logall` e `logall_json` sono disabilitati;
- il manager non conserva necessariamente il singolo evento non allertante.

## Retention e impatto sui TN

`ENV-2026-08` mantiene `logall=no` e `logall_json=no`. Per i TN il criterio corretto è quindi:

- provare localmente che l'attività benigna sia avvenuta quando necessario;
- verificare che la rule target sia assente;
- non affermare che il manager abbia persistito il singolo evento non allertante se non esiste evidenza specifica.

## Interpretazione corretta

Queste regole validano pipeline, campi e selettività del laboratorio, ma non dimostrano da sole un attacco. Una detection operativa deve aggiungere contesto, frequenza, ruolo host, sequenza temporale e comportamento correlato.

## Workflow aggiornato

1. fissare expected telemetry e expected detection prima del test;
2. generare un marker univoco o un oggetto di test identificabile;
3. conservare localmente l'evidenza dell'azione;
4. correlare il record locale con l'alert manager quando disponibile;
5. eseguire TP e TN distinti;
6. classificare eventuali artefatti del test harness;
7. eseguire cleanup e verificarne la telemetria;
8. misurare latency, coverage, precision e data quality;
9. ripetere dopo rollback;
10. pubblicare soltanto evidenze sanificate.

## Metriche ancora da chiudere

- detection latency;
- triage latency;
- coverage della catena;
- precision;
- data quality;
- repeatability;
- cleanup completeness globale.

## Gate successivo

La fase rimane `IN PROGRESS`. Retention e matrice TP/TN sono concluse; servono ancora tuning, metriche, smoke test coordinato e ripetizione dopo rollback prima di dichiarare il nucleo `LOGGING-READY`.

Riferimenti:

- `../03-telemetry-baseline/README.md`
- `../../evidence/sanitized/ENV-2026-08-retention-baseline.md`
- `../../evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md`
- `../../templates/detection-test.md`
