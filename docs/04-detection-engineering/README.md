# 04 - Detection engineering

**Stato:** `IN PROGRESS`  
**Checkpoint:** `ENV-2026-05 — pipeline Wazuh ↔ sinkhole isolata`  
**Ambito validato:** regole tecniche per telemetria HTTP JSONL 200/404/405  
**Ambito non ancora validato:** detection delle campagne e matrice TP/TN completa

## Stato delle fonti

| Fonte | Stato per detection |
|---|---|
| Sinkhole JSONL | acquisita, decodificata e validata senza egress |
| Wazuh Agent Linux | Active tramite `lab-lan` |
| Wazuh manager/indexer/dashboard | operativi e isolati |
| Sysmon | non disponibile |
| PowerShell 4104 | non disponibile |
| Security 4698/4699 | non disponibile |
| auditd | non disponibile |
| Wazuh FIM appliance | non disponibile |

## Regole tecniche validate

| Rule ID | Livello | Condizione | Scopo |
|---:|---:|---|---|
| `100100` | 0 | JSON proveniente da `requests.jsonl` | regola padre, nessun alert |
| `100101` | 3 | `status=200` e `path=/heartbeat` | conferma heartbeat LAB |
| `100102` | 5 | `status=404` | percorso inesistente da osservare |
| `100103` | 7 | `status=405` | metodo HTTP non consentito |

La regola padre limita il matching agli eventi JSON del sinkhole. Il campo `status` è statico nel motore Wazuh e viene confrontato con il tag `<status>`.

Regola pubblica:

- [`../../configs/wazuh/rules/tio_sinkhole_rules.xml`](../../configs/wazuh/rules/tio_sinkhole_rules.xml)

## Validazione eseguita

- controllo di assenza conflitti sugli ID;
- test di sintassi con `wazuh-analysisd -t`;
- test 200, 404 e 405 con `wazuh-logtest`;
- riavvio controllato del manager;
- generazione di richieste HTTP reali;
- verifica degli alert in `alerts.json`;
- verifica dell'inoltro tramite Filebeat;
- verifica degli eventi nell'indexer;
- ricerca nel Threat Hunting mediante Rule ID;
- rimozione della NAT da WAZUH-LAB;
- ripetizione dei tre eventi con pipeline isolata;
- verifica di servizi, indexer green e agent Active dopo riavvio;
- snapshot `WAZUH-PIPELINE-READY` creato a VM spenta.

Query DQL verificata nel campo Search:

```text
rule.id:100101 or rule.id:100102 or rule.id:100103
```

## Interpretazione corretta

Queste regole validano la pipeline e la disponibilità dei campi, ma non dimostrano da sole un attacco:

- il heartbeat 200 è un evento atteso;
- un singolo 404 può derivare da errore umano o test amministrativo;
- un singolo 405 può derivare da un controllo benigno;
- la severità corrente è didattica e richiede tuning;
- una detection operativa dovrebbe considerare frequenza, ruolo dell'host, sequenza temporale e processo origine.

## Workflow per le regole successive

1. Eseguire il comportamento positivo e conservare l'evento raw nello storage privato.
2. Verificare che il parser esponga campi stabili.
3. Scrivere la regola usando campi strutturati.
4. Testare Rule ID, livello e descrizione.
5. Eseguire TP2 con variante dello stesso comportamento.
6. Eseguire TN1 amministrativo.
7. Eseguire TN2 basato sul ruolo dell'host.
8. Aggiungere contesto invece di esclusioni globali.
9. Misurare latenza, qualità e precisione.
10. Ripetere dopo rollback e verificare cleanup.

## Matrice minima ancora da completare

| Test | Esito atteso |
|---|---|
| TP1 comportamento esatto | alert con campi corretti |
| TP2 variante | alert ancora presente |
| TN1 amministrativo | nessun alert high o alert contestualizzato |
| TN2 host role | severity ridotta o allowlist condizionata |
| Resilienza | cambio nome o path non irrilevante non rompe la logica |
| Cleanup | nessun artefatto residuo |
| Rollback | stesso risultato dalla baseline ripristinata |

## Metriche da raccogliere

- detection latency;
- triage latency;
- coverage della catena;
- precision;
- data quality;
- repeatability;
- cleanup completeness.

## Gate successivo

La fase rimane `IN PROGRESS`. Per validare il nucleo di detection servono ancora:

- almeno due test negativi formali;
- tuning basato su frequenza e contesto;
- misurazione delle metriche;
- conservazione privata dell'evento raw con manifest;
- ripetizione dopo rollback;
- telemetria Windows e appliance per le campagne.

Riferimenti:

- [`../03-telemetry-baseline/README.md`](../03-telemetry-baseline/README.md)
- [`../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`](../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md)
- [`../../templates/detection-test.md`](../../templates/detection-test.md)
