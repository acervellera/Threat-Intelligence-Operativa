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
- `ENV-2026-08 — retention finale multi-nodo`, PASS;
- `ENV-2026-09 — matrice formale TP/TN`, 14/14 PASS;
- rete host-only `10.10.10.0/24` validata senza forwarding;
- NTP interno `10.10.10.1` validato;
- quattro nodi principali isolati e privi di default route;
- snapshot `*-TELEMETRY-READY` creati a VM spenta.

Nessuna campagna deve essere avviata finché metriche, smoke test coordinato, rollback, verifica globale baseline/cleanup e snapshot finali non portano la Track A a `LOGGING-READY`.

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

## Gate completati

1. hypervisor KVM/QEMU e libvirt;
2. rete host-only senza forwarding;
3. sinkhole HTTP/JSONL;
4. Wazuh all-in-one e pipeline JSONL;
5. telemetria Windows e dataset sintetico;
6. auditd e FIM Whodata su appliance;
7. NTP interno sui quattro nodi;
8. rimozione delle NIC NAT;
9. test isolati per le sorgenti principali;
10. snapshot `*-TELEMETRY-READY`;
11. retention finale;
12. matrice formale 8 TP + 6 TN, 14/14 PASS.

## Prossimi gate Track A

1. metriche di latency, coverage, precision, data quality e repeatability;
2. smoke test coordinato dei quattro nodi;
3. ripetizione completa dopo rollback;
4. cleanup e verifica baseline globali;
5. inventario globale degli snapshot;
6. snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`;
7. primo caso benigno completo.

## Contratto Track A per ogni caso

Ogni lab benigno deve contenere almeno:

- `case-brief.md`;
- `runbook.md`;
- mapping ATT&CK;
- evidence register e timeline UTC;
- detection test positivo e negativo;
- finding e incident response;
- cleanup checklist;
- publication checklist;
- metriche e gap;
- esito della ripetizione da snapshot.

## Track B

Ordine operativo:

1. completare `LOGGING-READY` e `LOGGING-READY-LINUX`;
2. completare il primo caso benigno end-to-end;
3. costruire una sola volta la Track B separata;
4. ripetere il primo caso iniziando dall'analisi statica;
5. eseguire dinamica soltanto quando appropriata e proporzionata;
6. confrontare documentato, emulato e osservato;
7. aggiornare detection, gap e report.

Gate di ingresso Track B:

- Track A a `LOGGING-READY`;
- primo caso benigno completato;
- subnet distinta senza routing verso `lab-lan` o rete reale;
- manager Wazuh e sinkhole separati;
- VM sacrificabili basate su immagini golden/overlay;
- cartelle condivise, clipboard e drag-and-drop disabilitati;
- storage privato per campioni ed evidenze contaminate;
- checklist di rischio, kill switch e rollback/distruzione.

La metodologia completa è in [`../docs/07-malware-analysis-track/README.md`](../docs/07-malware-analysis-track/README.md).

## Dipendenza operativa

```text
SINKHOLE-TELEMETRY-READY
      +
WAZUH-TELEMETRY-READY
      +
WIN11-TELEMETRY-READY
      +
APPLIANCE-TELEMETRY-READY
      +
retention PASS
      +
TP/TN 14/14 PASS
      +
metriche + smoke test + rollback + cleanup
      =
LOGGING-READY
```

La Track B resta `PLANNED / BLOCKED` finché non esistono `LOGGING-READY` e un primo caso Track A completato end-to-end.
