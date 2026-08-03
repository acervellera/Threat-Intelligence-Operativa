# 03 - Baseline di telemetria

## Eventi prioritari

| Fonte | Evento | Uso | Limite |
|---|---|---|---|
| Sysmon | 1 Process Create | process tree, command line, hash, parent | non prova l'intento |
| Sysmon | 3 Network Connect | connessioni verso sinkhole | può essere filtrato per volume |
| Sysmon | 11 File Create | Startup, staging, extension, marker | non registra ogni lettura |
| Sysmon | 12-14 Registry | Run key, service e policy | richiede filtri mirati |
| Sysmon | 15 FileCreateStreamHash | ADS nel caso WinRAR | non prova lo sfruttamento |
| Sysmon | 22 DNS Query | nomi LAB e periodicità | DoH applicativo può sfuggire |
| PowerShell | 4104 | contenuto script e decodifica | può contenere dati sensibili |
| Security | 4698/4699 | create/delete scheduled task | richiede auditing avanzato |
| System | 7045 | creazione servizio | contesto utente limitato |
| Wazuh FIM/auditd | file integrity / execve | appliance Linux | tuning indispensabile |

## Smoke test

La pipeline è valida quando:

1. un processo di prova appare in Sysmon;
2. un file marker appare in Sysmon 11 o FIM;
3. una richiesta heartbeat appare nel sinkhole;
4. l'evento raggiunge Wazuh con `agent.name`, Event ID e command line;
5. il cleanup rimuove il marker;
6. la stessa prova è ripetibile dopo rollback.

## Gap da dichiarare

- Sysmon non vede tutte le letture di file sensibili;
- accessi a browser store richiedono 4663, FIM, EDR o telemetria dedicata;
- token theft, DPAPI e AMSI bypass non hanno un singolo evento universale;
- appliance richiedono log centralizzati, auditd, FIM e rete.
