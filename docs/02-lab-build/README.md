# 02 - Costruzione del laboratorio

**Stato:** `IN PROGRESS`  
**Checkpoint corrente:** `ENV-2026-03 — SINKHOLE-LAB CLEAN-OS`

## Topologia

| Nodo | IP suggerito | Ruolo | Stato |
|---|---|---|---|
| Host Ubuntu / bridge libvirt | `10.10.10.1` | Gestione locale della rete LAB | VALIDATED |
| WIN11-LAB | `10.10.10.20` | Sysmon, PowerShell logging, Wazuh agent, browser disposable | NOT STARTED |
| SINKHOLE-LAB | `10.10.10.30` | HTTP GET/POST interno, heartbeat e JSONL | CLEAN-OS READY |
| WAZUH-LAB | `10.10.10.40` | Manager, indexer, dashboard e retention | NOT STARTED |
| APPLIANCE-LAB | `10.10.10.50` | auditd, FIM e laboratorio BRICKSTORM | NOT STARTED |
| ANALYST-LAB | `10.10.10.60` | Analisi, timeline, report e hash | OPTIONAL |

## Stato verificato della rete

La rete libvirt `lab-lan` usa la subnet `10.10.10.0/24` e il bridge host `10.10.10.1`. La configurazione non contiene alcun elemento `<forward>`, quindi non fornisce NAT o routing verso la LAN reale.

Configurazione pubblica ridotta:

- [`configs/libvirt/lab-lan.sanitized.xml`](../../configs/libvirt/lab-lan.sanitized.xml)

Evidenza del primo nodo:

- [`evidence/sanitized/ENV-2026-03-sinkhole-baseline.md`](../../evidence/sanitized/ENV-2026-03-sinkhole-baseline.md)

## Vincoli di rete

- rete host-only `10.10.10.0/24`;
- nessun bridge alla LAN domestica o aziendale;
- NAT solo per installazione e patching, poi rimosso;
- egress deny predefinito;
- traffico consentito solo tra nodi LAB e host di gestione;
- nessuna default route sulle VM isolate;
- DNS e orari registrati, report in UTC.

## Baseline SINKHOLE-LAB

Configurazione validata il `2026-08-03 UTC`:

| Parametro | Valore |
|---|---|
| Guest | Debian 13 amd64 |
| Risorse | 2 vCPU, 2 GiB RAM, QCOW2 |
| Hostname | `sinkhole-lab` |
| FQDN | `sinkhole-lab.lab.internal` |
| Rete finale | `lab-lan` soltanto |
| IPv4 | `10.10.10.30/24` |
| Default route | assente |
| Internet | non raggiungibile |
| Gestione | SSH dalla macchina host |
| Runtime | Python 3.13 |
| Integrazione | QEMU Guest Agent e SPICE Guest Agent |
| Snapshot | `CLEAN-OS`, creato a VM spenta |

## Sequenza di build

1. Installare hypervisor e creare rete host-only.
2. Creare una VM con NAT temporaneo e scheda `lab-lan`.
3. Installare e aggiornare il sistema operativo.
4. Configurare l'indirizzo statico LAB senza gateway.
5. Verificare SSH e la comunicazione con `10.10.10.1`.
6. Rimuovere la scheda NAT.
7. Verificare assenza di default route e accesso Internet.
8. Creare snapshot `CLEAN-OS` a VM spenta.
9. Pubblicare soltanto configurazioni ed evidenze sanificate.
10. Ripetere il processo per WIN11-LAB, WAZUH-LAB e APPLIANCE-LAB.

## Prossimo checkpoint

Implementare su SINKHOLE-LAB:

- servizio HTTP interno su `10.10.10.30:8080`;
- endpoint benigno `/heartbeat`;
- logging JSONL;
- esecuzione tramite utente dedicato e servizio `systemd`;
- nessun upload, comando remoto o esecuzione di contenuti ricevuti.

Successivamente:

1. creare WAZUH-LAB;
2. creare WIN11-LAB;
3. creare APPLIANCE-LAB;
4. installare la telemetria;
5. eseguire smoke test;
6. creare `LOGGING-READY` e `LOGGING-READY-LINUX`.

La guida eseguibile e la checklist completa sono in [`labs/00-environment`](../../labs/00-environment/README.md).
