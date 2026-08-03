# 02 - Costruzione del laboratorio

## Topologia

| Nodo | IP suggerito | Ruolo |
|---|---|---|
| WIN11-LAB | 10.10.10.20 | Sysmon, PowerShell logging, Wazuh agent, browser disposable |
| SINKHOLE-LAB | 10.10.10.30 | HTTP GET/POST interno, file benigni, JSONL |
| WAZUH-LAB | 10.10.10.40 | Manager, indexer, dashboard e retention |
| APPLIANCE-LAB | 10.10.10.50 | auditd, FIM e laboratorio BRICKSTORM |
| ANALYST-LAB | 10.10.10.60 | Analisi, timeline, report e hash |

## Vincoli di rete

- rete host-only `10.10.10.0/24`;
- nessun bridge alla LAN domestica o aziendale;
- NAT solo per installazione e patching, poi disabilitato;
- egress deny predefinito;
- traffico consentito solo tra nodi LAB;
- DNS e orari registrati, report in UTC.

## Sequenza di build

1. Installare VM e patch; snapshot `CLEAN-OS`.
2. Installare Wazuh e registrare agent.
3. Installare Sysmon e applicare configurazione di laboratorio.
4. Abilitare PowerShell 4104, Task Scheduler e 4698/4699.
5. Creare dataset sintetico.
6. Avviare sinkhole su `10.10.10.30:8080`.
7. Configurare EventChannel Wazuh.
8. Importare regole custom e usare `wazuh-logtest`.
9. Eseguire smoke test.
10. Creare snapshot `LOGGING-READY` e `LOGGING-READY-LINUX`.

La guida eseguibile è in [`labs/00-environment`](../../labs/00-environment/README.md).
