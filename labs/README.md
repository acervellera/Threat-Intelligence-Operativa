# Laboratori

Eseguire i laboratori in ordine. Ogni cartella è un progetto autonomo, ma tutte dipendono da `00-environment` e dagli snapshot globali `LOGGING-READY` o `LOGGING-READY-LINUX`.

## Stato corrente

La fase `00-environment` è `IN PROGRESS`.

Checkpoint disponibili:

- `ENV-2026-03 — SINKHOLE-LAB CLEAN-OS`;
- `ENV-2026-04 — SINKHOLE-READY`;
- `ENV-2026-05 — WAZUH-PIPELINE-READY`;
- `ENV-2026-06 — WIN11/SINKHOLE/WAZUH TELEMETRY-READY`;
- `ENV-2026-07 — APPLIANCE-TELEMETRY-READY`;
- rete host-only `10.10.10.0/24` validata senza forwarding;
- NTP interno `10.10.10.1` validato;
- quattro nodi principali isolati e privi di default route;
- telemetria Windows, sinkhole, auditd e FIM Whodata verificata;
- snapshot `*-TELEMETRY-READY` creati a VM spenta;
- evidenze sanificate e configurazioni pubblicate.

Nessuna campagna deve essere avviata finché retention, TP/TN, metriche, smoke test coordinato, rollback e snapshot globali non portano la Track A a `LOGGING-READY`.

## Percorso Track A

| Ordine | Caso | Obiettivo sintetico | Stato |
|---:|---|---|---|
| 0 | [Environment](00-environment/README.md) | Costruire rete, Wazuh, Sysmon, auditd, sinkhole e dataset | IN PROGRESS |
| 1 | CaptiveCrunch / Storm-2945 | ClickFix → PowerShell → persistenza simulata → browser debug sintetico → heartbeat | BLOCKED |
| 2 | ACR Stealer | Chain A Python/task/resolver e Chain B MSHTA/marker, con dati sintetici | BLOCKED |
| 3 | UNC1069 | social engineering → inventory → estensione sintetica → staging → POST interno | BLOCKED |
| 4 | UNC3753 / Luna Moth | vishing → remote support benigno → staging → archivio sintetico → upload interno | BLOCKED |
| 5 | BRICKSTORM | systemd benigno → FIM/auditd → marker applicativo → heartbeat | BLOCKED |
| 6 | WinRAR CVE-2025-8088 | estrazione controllata → ADS benigno → Startup simulata → marker | BLOCKED |

`BLOCKED` indica che il caso è documentato ma non deve essere eseguito prima del completamento dei gate dell'ambiente.

## Ordine operativo delle due track

1. completare `LOGGING-READY` e `LOGGING-READY-LINUX` nella Track A;
2. completare il primo caso con emulazione esclusivamente benigna;
3. verificare detection, TP/TN, cleanup, rollback, evidenze e reporting;
4. costruire una sola volta la Track B separata;
5. ripetere il primo caso iniziando dall'analisi statica;
6. svolgere dinamica soltanto quando appropriata e proporzionata;
7. confrontare fonti, emulazione e comportamento osservato;
8. aggiornare detection e report;
9. proseguire con lo stesso ciclo per i casi successivi.

La metodologia della Track B è definita in [`../docs/07-malware-analysis-track/README.md`](../docs/07-malware-analysis-track/README.md).

## Contratto Track A per ogni caso

Ogni lab benigno deve contenere:

- `case-brief.md`;
- `runbook.md`;
- `attack-map.csv` o Navigator JSON;
- `evidence-register.csv`;
- `timeline.csv`;
- `detection-test.md`;
- `pentest-finding.md`;
- `incident-response.md`;
- `cleanup-checklist.md`;
- `publication-checklist.md`.

Ogni caso Track A deve inoltre dichiarare:

- dati e percorsi sintetici utilizzati;
- test positivi e negativi;
- marker univoci;
- kill switch;
- cleanup;
- stato della baseline prima e dopo;
- esito della ripetizione da snapshot;
- metriche e gap di telemetria.

Questi file vanno creati man mano a partire dai modelli in `templates/`.

## Estensione Track B per ogni caso

Dopo l'attivazione della Track B, il caso deve aggiungere:

- decisione documentata sulla provenienza e autorizzazione del campione;
- analisi statica prima di qualsiasi esecuzione;
- valutazione del rischio e decisione motivata sulla dinamica;
- timeline separata della Track B;
- matrice `documentato-vs-emulato-vs-osservato`;
- differenze nel process tree, file, registro, persistenza, rete ed eventi;
- detection prima e dopo il tuning;
- record di rollback o distruzione dell'ambiente contaminato;
- report pubblico esclusivamente difensivo e sanificato.

La dinamica non è obbligatoria per tutti i casi. Campioni ad alto rischio possono essere limitati all'analisi statica o richiedere un host dedicato.

## Gate completati

1. hypervisor KVM/QEMU e libvirt;
2. rete host-only senza forwarding;
3. baseline e sinkhole HTTP;
4. Wazuh all-in-one e pipeline JSONL;
5. telemetria Windows e dataset sintetico;
6. auditd e FIM Whodata su appliance;
7. NTP interno sui quattro nodi;
8. rimozione delle NIC NAT;
9. test isolati per le sorgenti principali;
10. snapshot `*-TELEMETRY-READY`.

## Prossimi gate Track A

1. retention finale;
2. matrice TP1, TP2, TN1 e TN2 multi-nodo;
3. metriche di latency, coverage, precision e data quality;
4. smoke test coordinato dei quattro nodi;
5. cleanup e verifica baseline;
6. ripetizione completa dopo rollback;
7. inventario globale degli snapshot;
8. snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`;
9. primo caso benigno completo.

## Gate di ingresso Track B

1. Track A a `LOGGING-READY`;
2. primo caso benigno completato end-to-end;
3. subnet distinta senza routing verso `lab-lan` o rete reale;
4. manager Wazuh e sinkhole separati;
5. VM sacrificabili basate su immagini golden e overlay;
6. cartelle condivise, clipboard e drag-and-drop disabilitati;
7. storage privato per campioni ed evidenze contaminate;
8. checklist di rischio, kill switch e procedura di distruzione/rollback.

## Dipendenza operativa

Le campagne Track A possono passare da `BLOCKED` a `NOT STARTED` soltanto quando:

```text
SINKHOLE-TELEMETRY-READY
      +
WAZUH-TELEMETRY-READY
      +
WIN11-TELEMETRY-READY
      +
APPLIANCE-TELEMETRY-READY
      +
retention + TP/TN + metriche
      +
smoke test + rollback + cleanup
      =
LOGGING-READY
```

La Track B può passare da `PLANNED / BLOCKED` a `IN PROGRESS` soltanto quando:

```text
LOGGING-READY
      +
primo caso Track A completo
      +
separazione e controlli sandbox validati
      =
TRACK-B-READY
```
