# 02 - Costruzione del laboratorio

**Stato:** `IN PROGRESS`  
**Checkpoint corrente:** `ENV-2026-04 — SINKHOLE-READY`  
**Prossimo nodo:** `WAZUH-LAB` su `10.10.10.40`

## Topologia

| Nodo | IP suggerito | Ruolo | Stato |
|---|---|---|---|
| Host Ubuntu / bridge libvirt | `10.10.10.1` | Gestione locale della rete LAB | VALIDATED |
| WIN11-LAB | `10.10.10.20` | Sysmon, PowerShell logging, Wazuh agent, browser disposable | NOT STARTED |
| SINKHOLE-LAB | `10.10.10.30` | HTTP interno, heartbeat e JSONL | SINKHOLE-READY |
| WAZUH-LAB | `10.10.10.40` | Manager, indexer, dashboard e retention | NEXT |
| APPLIANCE-LAB | `10.10.10.50` | auditd, FIM e laboratorio BRICKSTORM | NOT STARTED |
| ANALYST-LAB | `10.10.10.60` | Analisi, timeline, report e hash | OPTIONAL |

## Stato verificato della rete

La rete libvirt `lab-lan` usa la subnet `10.10.10.0/24` e il bridge host `10.10.10.1`. La configurazione non contiene alcun elemento `<forward>`, quindi non fornisce NAT o routing verso la LAN reale.

Configurazione pubblica ridotta:

- [`configs/libvirt/lab-lan.sanitized.xml`](../../configs/libvirt/lab-lan.sanitized.xml)

Evidenze:

- [`ENV-2026-03 — CLEAN-OS`](../../evidence/sanitized/ENV-2026-03-sinkhole-baseline.md)
- [`ENV-2026-04 — SINKHOLE-READY`](../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md)

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
| Snapshot base | `CLEAN-OS`, creato a VM spenta |
| Snapshot applicativo | `SINKHOLE-READY`, figlio di `CLEAN-OS` |

## Servizio sinkhole validato

| Parametro | Valore |
|---|---|
| Unità | `tio-sinkhole.service` |
| Utente | `tio-sinkhole` |
| Bind | `10.10.10.30:8080` |
| Endpoint | `/heartbeat` |
| Metodi permessi | GET, HEAD |
| Metodi rifiutati | POST, PUT, PATCH, DELETE |
| Log | `/var/log/tio-sinkhole/requests.jsonl` |
| Formato | JSONL |
| Rotazione | giornaliera, 14 archivi, `maxsize 10M` |
| Health check | 16 PASS, 0 FAIL |

Componenti pubblici:

- [`configs/sinkhole/server.py`](../../configs/sinkhole/server.py)
- [`configs/sinkhole/tio-sinkhole.service`](../../configs/sinkhole/tio-sinkhole.service)
- [`configs/sinkhole/tio-sinkhole.logrotate`](../../configs/sinkhole/tio-sinkhole.logrotate)
- [`scripts/common/tio-sinkhole-check.sh`](../../scripts/common/tio-sinkhole-check.sh)

Guida completa: [`configs/sinkhole/README.md`](../../configs/sinkhole/README.md).

## Sequenza di build validata

1. Installare hypervisor e creare rete host-only.
2. Creare una VM con NAT temporaneo e scheda `lab-lan`.
3. Installare e aggiornare il sistema operativo.
4. Configurare l'indirizzo statico LAB senza gateway.
5. Verificare SSH e la comunicazione con `10.10.10.1`.
6. Rimuovere la scheda NAT.
7. Verificare assenza di default route e accesso Internet.
8. Creare snapshot `CLEAN-OS` a VM spenta.
9. Installare il componente applicativo previsto per la VM.
10. Eseguire test positivo, test negativo, verifica privilegi e verifica log.
11. Configurare retention e health check ripetibile.
12. Creare uno snapshot applicativo intermedio a VM spenta.
13. Pubblicare soltanto configurazioni ed evidenze sanificate.
14. Ripetere il processo per WAZUH-LAB, WIN11-LAB e APPLIANCE-LAB.

## Test del sinkhole

La matrice validata è:

| Origine | Richiesta | Esito |
|---|---|---|
| SINKHOLE-LAB | `GET /heartbeat` | 200 |
| SINKHOLE-LAB | `GET /percorso-inesistente` | 404 |
| SINKHOLE-LAB | `POST /heartbeat` | 405 |
| Host LAB `10.10.10.1` | `GET /heartbeat` | 200 |
| Host LAB `10.10.10.1` | `GET /inesistente` | 404 |
| Host LAB `10.10.10.1` | `POST /heartbeat` | 405 |

Gli eventi provenienti dall'host sono stati registrati con `client_ip` uguale a `10.10.10.1`.

## Prossimi checkpoint

Ordine operativo corrente:

1. creare WAZUH-LAB;
2. installare Wazuh all-in-one;
3. rimuovere il NAT da WAZUH-LAB e verificare isolamento;
4. acquisire e decodificare il JSONL del sinkhole;
5. creare WIN11-LAB e telemetria Windows;
6. creare APPLIANCE-LAB e telemetria Linux;
7. eseguire smoke test end-to-end;
8. ripetere il test dopo rollback;
9. creare `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Limiti del checkpoint corrente

`SINKHOLE-READY` non è ancora la baseline finale del laboratorio. Mancano:

- Wazuh manager, indexer e dashboard;
- agent Windows e Linux;
- Sysmon, PowerShell logging, auditd e FIM;
- dataset sintetico;
- ingestione e parsing dei log JSONL;
- smoke test completo;
- rollback testato;
- snapshot `LOGGING-READY`.

La guida eseguibile e la checklist completa sono in [`labs/00-environment`](../../labs/00-environment/README.md).
