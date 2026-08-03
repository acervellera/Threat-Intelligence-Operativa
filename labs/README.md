# Laboratori

Eseguire i laboratori in ordine. Ogni cartella è un progetto autonomo, ma tutte dipendono da `00-environment` e dallo snapshot `LOGGING-READY`.

| Ordine | Caso | Obiettivo sintetico |
|---:|---|---|
| 0 | Environment | Costruire rete, Wazuh, Sysmon, auditd, sinkhole e dataset |
| 1 | CaptiveCrunch | ClickFix -> PowerShell -> Run key/task -> browser debug -> heartbeat |
| 2 | ACR Stealer | Chain A Python/task/resolver e Chain B MSHTA/marker |
| 3 | UNC1069 | social engineering -> inventory -> extension -> staging -> POST |
| 4 | UNC3753 | vishing -> remote support benigno -> staging -> archive -> upload |
| 5 | BRICKSTORM | systemd benigno -> FIM/auditd -> JSP marker -> heartbeat |
| 6 | WinRAR | ADS benigno -> Startup LNK -> marker -> inventory patch |

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
