# Laboratori

Eseguire i laboratori in ordine. Ogni cartella è un progetto autonomo, ma tutte dipendono da `00-environment` e dallo snapshot `LOGGING-READY`.

## Stato corrente

La fase `00-environment` è `IN PROGRESS`.

Checkpoint disponibile:

- `ENV-2026-03 — SINKHOLE-LAB CLEAN-OS`;
- rete host-only `10.10.10.0/24` validata;
- SINKHOLE-LAB isolata su `10.10.10.30/24`;
- snapshot `CLEAN-OS` creato;
- evidenza sanificata pubblicata.

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

## Prossimi gate

1. servizio sinkhole HTTP con `/heartbeat` e log JSONL;
2. WAZUH-LAB;
3. WIN11-LAB e telemetria Windows;
4. APPLIANCE-LAB e telemetria Linux;
5. smoke test end-to-end;
6. snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

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
