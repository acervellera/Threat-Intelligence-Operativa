# ENV-2026-10 — Metriche di detection e qualità dei dati

**Classificazione:** SANITIZED  
**Data UTC:** 2026-08-07  
**Sorgente metodologica:** checkpoint `ENV-2026-09` congelato e verificato tramite manifesto SHA-256 privato.  
**Esito:** PASS

## Obiettivo

Misurare in modo riproducibile l'efficacia del set di test controllato, la selettività dei True Negative, la precisione degli alert, la latenza osservabile e la completezza dei campi necessari al triage.

Le metriche descrivono esclusivamente questo laboratorio isolato e sintetico. Non rappresentano copertura generale MITRE ATT&CK, prestazioni di produzione o capacità universali di un SOC.

## Risultati

| Metrica | Risultato |
|---|---:|
| Scenari pianificati completati | 14/14 — 100,00% |
| Efficacia True Positive | 8/8 — 100,00% |
| Selettività True Negative | 6/6 — 100,00% |
| Alert target intenzionali | 10 |
| Artefatti noti del test harness | 3 |
| Falsi positivi target non spiegati | 0 |
| Precisione grezza degli alert | 76,92% |
| Precisione classificata sul set controllato | 100,00% |
| Campioni di latenza misurabili | 8/10 |
| Latenza minima osservata | 0,194 s |
| Latenza media osservata | 0,875 s |
| Latenza mediana osservata | 1,034 s |
| Latenza massima osservata | 1,170 s |
| Completezza campi per detection/triage | 68/68 — 100,00% |

## Precisione degli alert

La precisione grezza include tre alert aggiuntivi generati accidentalmente dal test harness durante la validazione PowerShell. Gli eventi non sono stati eliminati dall'evidenza: sono stati classificati separatamente dopo correlazione con gli eventi sorgente.

La precisione classificata pari al 100,00% significa che, nel set controllato, non sono rimasti falsi positivi target non spiegati dopo la classificazione causale. Non è una stima della precisione in produzione.

## Latenza

La latenza è calcolata come differenza tra timestamp dell'alert Wazuh e timestamp dell'evento sorgente correlato. Il calcolo viene accettato soltanto quando i due timestamp sono disponibili e correlabili in modo affidabile.

Gli otto campioni misurabili coprono sinkhole HTTP, PowerShell, Task Scheduler/Security e auditd. I due scenari FIM sono marcati `NON_MISURABILE` per la metrica di latenza, perché l'evidenza disponibile non fornisce una coppia di timestamp sorgente/alert sufficientemente omogenea per applicare lo stesso criterio senza introdurre una stima artificiale.

## Qualità dei dati

Sono stati verificati 68 campi attesi su 10 alert rappresentativi. Tutti i campi richiesti dal criterio definito per detection e triage erano presenti.

Il criterio include, a seconda della sorgente, timestamp, rule ID, agent ID, metodo/path/status HTTP, Event ID/Record ID/SystemTime Windows, campi auditd utili a attribuzione e comando, e campi FIM relativi a evento, percorso, Whodata, processo e hash old/new quando applicabili.

## Ripetibilità

Nel checkpoint `ENV-2026-10` la ripetibilità era ancora `NOT_MEASURED`. È stata misurata successivamente in `ENV-2026-11` mediante rollback coordinato e ripetizione di un set rappresentativo TP/TN per le quattro pipeline.

## Sanificazione

Non sono pubblicati:

- log o JSON raw;
- marker completi di esecuzione;
- Record ID, ScriptBlock ID o identificatori host;
- percorsi dello storage privato;
- hash di archivi privati;
- credenziali o chiavi agent.

I dataset di calcolo, gli script di metrica, i manifesti e le visualizzazioni originali restano conservati nello storage privato verificato.