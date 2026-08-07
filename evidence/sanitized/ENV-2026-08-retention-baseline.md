# ENV-2026-08 — Retention baseline

**Classificazione:** `SANITIZED`  
**Data:** `2026-08-07 UTC`  
**Esito:** `PASS`  
**Ambito:** WAZUH-LAB, SINKHOLE-LAB, WIN11-LAB, APPLIANCE-LAB

## Obiettivo

Verificare che i quattro nodi principali dispongano di una retention coerente con il laboratorio, senza abilitare raccolte raw non necessarie e senza introdurre dipendenze da Internet.

## Risultato sintetico

| Nodo | Controllo | Esito |
|---|---|---|
| WAZUH-LAB | capacità disco, rotazione alert, journal, indexer, `logall/logall_json` | PASS |
| SINKHOLE-LAB | `logrotate` JSONL, compressione e timer | PASS |
| APPLIANCE-LAB | policy `auditd`, rotazione e comportamento low-space/full | PASS |
| WIN11-LAB | capacità Event Log e modalità circolare dei canali principali | PASS |

## WAZUH-LAB

La baseline finale mantiene `logall=no` e `logall_json=no`: il manager conserva gli alert e non archivia automaticamente tutti gli eventi non allertanti. La rotazione datata degli alert è presente; lo spazio disponibile e le dimensioni correnti di log, indexer e journal sono stati verificati con margine adeguato per il laboratorio.

Questa scelta riduce crescita eccessiva dello storage, ma introduce un limite osservativo dichiarato: per un true negative è possibile dimostrare l'assenza dell'alert target, non la persistenza sul manager del singolo evento non allertante.

## SINKHOLE-LAB

La rotazione del JSONL è configurata con:

- frequenza giornaliera;
- 14 rotazioni;
- soglia massima 10 MiB;
- compressione con `delaycompress`;
- timer di rotazione attivo.

Lo spazio disponibile è stato verificato prima della chiusura del checkpoint.

## APPLIANCE-LAB

`auditd` usa una policy locale con:

- `max_log_file = 8 MiB`;
- `num_logs = 5`;
- rotazione dei log;
- inoltro a syslog in condizione di spazio basso;
- sospensione in condizioni estreme di filesystem pieno o errore disco.

La dimensione corrente di `audit.log` e lo spazio libero del filesystem sono stati verificati.

## WIN11-LAB

I canali principali sono `Enabled=True` e in modalità circolare. Le capacità finali validate sono:

| Canale | Capacità finale |
|---|---:|
| Security | 128 MiB |
| Sysmon Operational | 128 MiB |
| PowerShell Operational | 64 MiB |
| TaskScheduler Operational | 32 MiB |
| System | 32 MiB |

La verifica privata include stato prima/dopo, health check e manifesto SHA-256. Il manifesto è stato costruito escludendo il proprio file per evitare self-hashing.

## Limiti

- il checkpoint valida la retention del laboratorio, non dimensiona un ambiente di produzione;
- `logall/logall_json` restano disabilitati intenzionalmente;
- le acquisizioni raw, i percorsi host, gli identificatori completi e i manifesti privati non sono pubblicati.

## Gate

`ENV-2026-08` chiude il requisito **retention finale** del gate Track A. Restano metriche, smoke test coordinato, rollback/ripetizione, inventario snapshot e snapshot globali `LOGGING-READY` / `LOGGING-READY-LINUX`.
