# ENV-2026-12 — Cleanup globale e baseline finale

**Classificazione:** SANITIZED  
**Data UTC:** 2026-08-10  
**Esito:** PASS

## Obiettivo

Verificare che, dopo i test di rollback e repeatability, i quattro nodi Track A fossero privi di residui operativi del test harness e ancora pienamente funzionanti prima della creazione degli snapshot finali.

## Ambito

- WIN11-LAB
- SINKHOLE-LAB
- WAZUH-LAB
- APPLIANCE-LAB

## Cleanup verificato

Su APPLIANCE-LAB sono stati rimossi esclusivamente gli artefatti operativi prodotti dai test di repeatability. I log e gli alert storici sono stati mantenuti come telemetria.

Risultato post-cleanup:

| Controllo | Esito |
|---|---:|
| File di test residui nel path FIM monitorato | 0 |
| File di test residui temporanei su appliance | 0 |
| Script temporanei del verificatore su Wazuh | 0 |

## Health check finale

| Nodo / servizio | Esito |
|---|---|
| Connettività ICMP dei quattro nodi | 4/4 PASS |
| Wazuh manager | active |
| Wazuh indexer | active |
| Filebeat | active |
| Wazuh dashboard | active |
| Sinkhole HTTP interno | active |
| Wazuh agent su sinkhole | active |
| auditd su appliance | active |
| Wazuh agent su appliance | active |
| WazuhSvc su Windows | Running |
| Sysmon su Windows | Running |
| W32Time su Windows | Running |

## Interpretazione

Il checkpoint dimostra che la baseline candidata agli snapshot finali non contiene residui operativi noti dei test e che le pipeline principali rimangono disponibili dopo il cleanup.

Non sono stati rimossi log, alert o altri dati storici necessari alla tracciabilità del laboratorio.

## Sanificazione

Non sono pubblicati percorsi locali dell'host, credenziali, identificatori macchina, log raw, record ID, marker completi o hash di archivi privati.

## Integrità privata

Il checkpoint privato è stato congelato con manifesto SHA-256 e verifica finale senza errori.

## Risultato

`ENV-2026-12 = PASS`
