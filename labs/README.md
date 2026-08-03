# Laboratori

Eseguire i laboratori in ordine. Ogni cartella è un progetto autonomo, ma tutte dipendono da `00-environment` e dallo snapshot `LOGGING-READY`.

## Stato corrente

La fase `00-environment` è `IN PROGRESS`.

Checkpoint disponibili:

- `ENV-2026-03 — SINKHOLE-LAB CLEAN-OS`;
- `ENV-2026-04 — SINKHOLE-READY`;
- rete host-only `10.10.10.0/24` validata;
- SINKHOLE-LAB isolata su `10.10.10.30/24`;
- servizio HTTP su `10.10.10.30:8080` validato;
- endpoint `/heartbeat`, log JSONL e logrotate operativi;
- health check automatico con 16 PASS e 0 FAIL;
- snapshot `CLEAN-OS` e `SINKHOLE-READY` creati a VM spenta;
- evidenze sanificate e configurazioni pubblicate.

Nessuna campagna deve essere avviata finché non esistono Wazuh, telemetria Windows/Linux, smoke test e snapshot `LOGGING-READY`.

## Percorso

| Ordine | Caso | Obiettivo sintetico | Stato |
|---:|---|---|---|
| 0 | [Environment](00-environment/README.md) | Costruire rete, Wazuh, Sysmon, auditd, sinkhole e dataset | IN PROGRESS |
| 1 | CaptiveCrunch | ClickFix -> PowerShell -> Run key/task -> browser debug -> heartbeat | BLOCKED |
| 2 | ACR Stealer | Chain A Python/task/resolver e Chain B MSHTA/marker | BLOCKED |
| 3 | UNC1069 | social engineering -> inventory -> extension -> staging -> POST | BLOCKED |
| 4 | UNC3753 | vishing -> remote support benigno -> staging -> archive -> upload | BLOCKED |
| 5 | BRICKSTORM | systemd benigno -> FIM/auditd -> JSP marker -> heartbeat | BLOCKED |
| 6 | WinRAR | ADS benigno -> Startup LNK -> marker -> inventory patch | BLOCKED |

`BLOCKED` indica che il caso è documentato ma non deve essere eseguito prima del completamento dei gate dell'ambiente.

## Gate completati

1. hypervisor KVM/QEMU e libvirt;
2. rete host-only senza forwarding;
3. baseline `CLEAN-OS` di SINKHOLE-LAB;
4. servizio sinkhole HTTP con test 200/404/405;
5. logging JSONL e rotazione;
6. health check ripetibile;
7. snapshot `SINKHOLE-READY`.

## Prossimi gate

1. WAZUH-LAB su `10.10.10.40`;
2. ingestione e parsing del JSONL del sinkhole;
3. WIN11-LAB e telemetria Windows;
4. APPLIANCE-LAB e telemetria Linux;
5. dataset sintetico;
6. smoke test end-to-end;
7. test dopo rollback;
8. snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Contratto comune

Ogni lab deve contenere:

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

Questi file vanno creati man mano a partire dai modelli in `templates/`.

## Dipendenza operativa

Le campagne potranno passare da `BLOCKED` a `NOT STARTED` soltanto quando:

```text
SINKHOLE-READY
      +
WAZUH-LAB
      +
WIN11-LAB / APPLIANCE-LAB
      +
telemetria validata
      +
smoke test ripetibile
      =
LOGGING-READY
```
