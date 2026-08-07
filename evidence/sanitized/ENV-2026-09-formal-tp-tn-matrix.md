# ENV-2026-09 — Matrice formale TP/TN multi-nodo

**Classificazione:** `SANITIZED`  
**Data:** `2026-08-07 UTC`  
**Esito:** `PASS`  
**Ambito:** WIN11-LAB, SINKHOLE-LAB, APPLIANCE-LAB, WAZUH-LAB

## Obiettivo

Eseguire una matrice formale di true positive e true negative sulle principali pipeline già validate, conservando le raw evidence nello storage privato e pubblicando soltanto risultati ridotti e riproducibili.

## Risultato

La matrice contiene **14 test**:

- **8 true positive**;
- **6 true negative**;
- **14/14 PASS**.

Il cleanup FIM `deleted -> 553` è stato verificato separatamente e non è contato come ulteriore TP della matrice.

## Matrice sanificata

| Test | Azione | Risultato atteso | Osservato | Esito |
|---|---|---|---|---|
| WIN-TP1 | PowerShell benigno con marker di test | Event 4104 -> rule `109910` | alert target presente; evento intenzionale isolato dagli artefatti del test harness | PASS |
| WIN-TP2 | creazione/cancellazione Scheduled Task benigna | `106 -> 67014`, `4698 -> 60228`, cleanup `141 -> 67015` | tutti i mapping richiesti presenti | PASS |
| WIN-TN1 | PowerShell 4104 benigno senza marker | nessuna `109910` | rule target assente | PASS |
| WIN-TN2 | comando Windows benigno non correlato | nessuna detection Windows target | `109910/67014/67015/60228 = 0` nella finestra | PASS |
| SINK-TP1 | GET `/heartbeat` | HTTP 200 -> `100101` | rule target presente; 404/405 assenti | PASS |
| SINK-TP2 | GET path inesistente | HTTP 404 -> `100102` | rule target presente; 200/405 assenti | PASS |
| SINK-TP3 | POST `/heartbeat` | HTTP 405 -> `100103` | rule target presente; 200/404 assenti | PASS |
| SINK-TN1 | heartbeat 200 | nessuna `100102` | rule 404 assente | PASS |
| SINK-TN2 | heartbeat 200 | nessuna `100103` | rule 405 assente | PASS |
| AUDIT-TP1 | esecuzione marker benigno sorvegliato | audit key `tio_appliance_exec` -> `80789` | `execve success=yes`, Agent `003`, rule target presente | PASS |
| AUDIT-TN1 | comando benigno fuori dalla watch execute | nessuna `80789` | rule target assente | PASS |
| FIM-TP1 | creazione file nel path monitorato | `added -> 554` | Whodata con utente/processo | PASS |
| FIM-TP2 | modifica contenuto nel path monitorato | `modified -> 550` | Whodata e cambio SHA-256 old/new | PASS |
| FIM-TN1 | creazione file fuori dal path monitorato | nessun alert FIM target | `550/553/554 = 0` per il marker TN | PASS |

## Finding metodologici

### PowerShell test-harness contamination

Durante `WIN-TP1` alcuni comandi diagnostici PowerShell contenevano letteralmente sia il marker della detection sia il RUN ID. Poiché Script Block Logging registra anche il codice di verifica, quei comandi hanno prodotto ulteriori Event ID 4104 e ulteriori `109910`.

L'evento intenzionale è stato separato tramite Record ID e ScriptBlock ID; gli altri alert sono stati classificati come **test-harness artifacts**. Il risultato rimane PASS, ma il metodo è stato corretto: i comandi diagnostici successivi non devono contenere letteralmente il trigger della detection.

### Security 4699

La cancellazione della Scheduled Task ha prodotto localmente Security Event ID `4699`, mentre non è stato osservato un alert Wazuh corrispondente in `alerts.json`. Questo risultato è classificato come **DISCOVERY**, non come FAIL: con `logall/logall_json` disabilitati non è possibile dimostrare dal manager se il singolo evento non allertante sia stato ricevuto e non persistito oppure non sia stato classificato da una rule con livello di alert.

### FIM Whodata

La creazione e modifica del file monitorato hanno esposto utente e processo; la modifica ha mostrato SHA-256 precedente e successivo. Il cleanup ha prodotto `deleted -> 553` con processo `rm`.

## Evidenze private

Lo storage privato conserva, separati per sorgente:

- eventi XML Windows locali;
- output locali auditd e FIM;
- eventi sinkhole JSONL;
- alert Wazuh completi;
- risultati leggibili;
- matrice finale congelata;
- manifesto SHA-256 finale verificato con esito `OK` per tutti i file inclusi.

Nel repository pubblico non sono inclusi log completi, percorsi host, UUID, MAC, chiavi agent, manifesti privati o hash di archivi non distribuiti.

## Gate

`ENV-2026-09` chiude il requisito **matrice formale TP/TN multi-nodo**. La Track A non è ancora `LOGGING-READY`: restano metriche formali, smoke test coordinato, ripetizione dopo rollback, controllo globale cleanup/baseline, inventario snapshot e snapshot finali coordinati.
