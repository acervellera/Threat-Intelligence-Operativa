# 00 - Costruzione e validazione dell'ambiente

**Stato:** IN PROGRESS  
**Fase primaria:** STEP-02 — Rete e VM  
**Ultimo checkpoint:** `ENV-2026-05 — pipeline Wazuh ↔ sinkhole isolata`  
**Prossimo checkpoint:** `WIN11-LAB` su `10.10.10.20`

## Obiettivo

Arrivare a una baseline ripetibile da cui iniziano tutti i casi, mantenendo separate:

- installazione e patching tramite NAT temporaneo;
- comunicazione operativa sulla rete host-only;
- evidenze raw conservate nello storage privato;
- evidenze pubbliche ridotte e sanificate.

## Stato della topologia

| Nodo | IP | Stato | Snapshot |
|---|---|---|---|
| Host Ubuntu / `lab-lan` | `10.10.10.1` | VALIDATED | n/a |
| WIN11-LAB | `10.10.10.20` | NEXT | - |
| SINKHOLE-LAB | `10.10.10.30` | SINKHOLE-READY, agent Active, isolata | `CLEAN-OS`, `SINKHOLE-READY` |
| WAZUH-LAB | `10.10.10.40` | WAZUH-PIPELINE-READY, isolata | `CLEAN-OS`, `WAZUH-READY`, `WAZUH-PIPELINE-READY` |
| APPLIANCE-LAB | `10.10.10.50` | NOT STARTED | - |
| ANALYST-LAB | `10.10.10.60` | OPTIONAL | - |

## Checkpoint ENV-2026-03 — CLEAN-OS sinkhole

- [x] Debian 13 amd64 aggiornato.
- [x] Hostname `sinkhole-lab` e dominio `lab.internal`.
- [x] IP statico `10.10.10.30/24`.
- [x] Collegamento finale esclusivamente a `lab-lan`.
- [x] Nessuna default route e nessun accesso Internet.
- [x] SSH e strumenti minimi.
- [x] Snapshot `CLEAN-OS` creato a VM spenta.

Evidenza: [`ENV-2026-03-sinkhole-baseline.md`](../../evidence/sanitized/ENV-2026-03-sinkhole-baseline.md).

## Checkpoint ENV-2026-04 — SINKHOLE-READY

- [x] servizio `systemd` non-root;
- [x] listener esclusivo su `10.10.10.30:8080`;
- [x] endpoint `GET/HEAD /heartbeat`;
- [x] test HTTP 200, 404 e 405;
- [x] log JSONL con campi strutturati;
- [x] logrotate giornaliero, 14 archivi e compressione;
- [x] health check 16 PASS / 0 FAIL;
- [x] isolamento senza default route;
- [x] snapshot `SINKHOLE-READY`.

Evidenza: [`ENV-2026-04-sinkhole-ready.md`](../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md).

## Checkpoint ENV-2026-05 — Pipeline Wazuh ↔ sinkhole isolata

### WAZUH-LAB

- [x] Ubuntu Server 24.04 LTS.
- [x] 4 vCPU e circa 8 GiB RAM.
- [x] IP statico `10.10.10.40/24` su `lab-lan`.
- [x] FQDN `wazuh-lab.lab.internal` e UTC.
- [x] filesystem LVM root esteso a circa 77 GiB.
- [x] snapshot `CLEAN-OS` prima dell'installazione Wazuh.
- [x] Wazuh all-in-one installato.
- [x] `wazuh-indexer`, `wazuh-manager`, `filebeat` e `wazuh-dashboard` active/enabled.
- [x] cluster indexer green e zero shard non assegnati.
- [x] dashboard HTTPS raggiungibile.
- [x] snapshot `WAZUH-READY` creato a VM spenta.
- [x] NIC NAT rimossa dalla configurazione persistente.
- [x] assenza di default route e indirizzo NAT dopo il riavvio.
- [x] egress Internet negato come previsto.
- [x] servizi Wazuh e dashboard verificati dopo isolamento.
- [x] snapshot `WAZUH-PIPELINE-READY` creato a VM spenta.
- [x] nuovo riavvio con servizi e agent ancora attivi.

### Agent su SINKHOLE-LAB

- [x] Wazuh Agent installato e registrato come `sinkhole-lab`.
- [x] agent `Active` sul manager.
- [x] connessione a `10.10.10.40:1514/tcp`.
- [x] NAT rimossa nuovamente da SINKHOLE-LAB.
- [x] nessuna default route.
- [x] comunicazione agent-manager confermata tramite `lab-lan` prima e dopo l'isolamento Wazuh.

### Ingestione JSONL e regole

- [x] configurato `<localfile>` su `/var/log/tio-sinkhole/requests.jsonl`.
- [x] formato `json` e label contestuali.
- [x] validazione `wazuh-logcollector -t` e `wazuh-agentd -t`.
- [x] logcollector conferma `Analyzing file`.
- [x] regola padre `100100`.
- [x] regola `100101` per heartbeat 200.
- [x] regola `100102` per 404.
- [x] regola `100103` per 405.
- [x] validazione con `wazuh-analysisd -t`.
- [x] test con `wazuh-logtest`.
- [x] alert verificati nel manager, indexer e dashboard.
- [x] test reale 200/404/405 ripetuto con WAZUH-LAB senza NAT.

Evidenza: [`ENV-2026-05-wazuh-sinkhole-pipeline.md`](../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md).

Configurazioni: [`configs/wazuh`](../../configs/wazuh/README.md).

## Flusso validato

```text
client LAB
   |
   | HTTP verso 10.10.10.30:8080
   v
SINKHOLE-LAB -> requests.jsonl -> Wazuh Agent
                                      |
                                      | TCP 1514 su lab-lan
                                      v
WAZUH-LAB -> Manager -> alerts.json -> Filebeat -> Indexer -> Dashboard
```

Entrambe le VM operative della pipeline sono prive di NAT e default route.

## Step 1 - Hypervisor e VM

- [x] Installare hypervisor con supporto snapshot.
- [x] Creare SINKHOLE-LAB.
- [x] Creare WAZUH-LAB.
- [ ] Creare WIN11-LAB: 2 vCPU, 8 GB RAM, 80 GB.
- [ ] Creare APPLIANCE-LAB: 2 vCPU, 2-4 GB RAM.
- [ ] Creare ANALYST-LAB opzionale.
- [ ] Aggiornare tutte le VM rimanenti e creare snapshot `CLEAN-OS`.

## Step 2 - Rete

- [x] Creare host-only `10.10.10.0/24`.
- [x] Assegnare IP a SINKHOLE-LAB e WAZUH-LAB.
- [x] Verificare assenza di bridge verso LAN reale.
- [x] Disabilitare NAT su SINKHOLE-LAB.
- [x] Applicare egress deny su SINKHOLE-LAB.
- [x] Disabilitare NAT su WAZUH-LAB.
- [x] Applicare egress deny su WAZUH-LAB.
- [x] Usare UTC sui nodi correnti.
- [ ] Configurare una sorgente NTP interna.
- [ ] Estendere isolamento, egress deny e UTC alle VM rimanenti.

## Step 3 - Sinkhole HTTP

- [x] applicazione HTTP benigna;
- [x] endpoint `/heartbeat`;
- [x] logging JSONL;
- [x] utente dedicato e hardening `systemd`;
- [x] rotazione e retention;
- [x] health check;
- [x] invio del JSONL a Wazuh;
- [ ] ripetere il health check dopo rollback da `SINKHOLE-READY`.

## Step 4 - Wazuh

- [x] creare WAZUH-LAB;
- [x] configurare `10.10.10.40/24`;
- [x] installare Wazuh all-in-one;
- [x] registrare agent Linux;
- [x] acquisire e decodificare il JSONL;
- [x] validare tre regole tecniche e dashboard;
- [x] rimuovere NAT da WAZUH-LAB;
- [x] verificare la pipeline isolata e creare `WAZUH-PIPELINE-READY`;
- [ ] definire retention finale;
- [ ] registrare agent Windows e appliance;
- [ ] ripetere la pipeline dopo rollback.

## Step 5 - Windows telemetry

- [ ] installare WIN11-LAB;
- [ ] installare Sysmon e applicare configurazione LAB;
- [ ] abilitare PowerShell Operational e Script Block Logging 4104;
- [ ] abilitare TaskScheduler/Operational;
- [ ] abilitare Security 4698/4699;
- [ ] configurare Wazuh EventChannel.

## Step 6 - Linux appliance telemetry

- [ ] installare APPLIANCE-LAB;
- [ ] installare auditd;
- [ ] configurare regole per execve, systemd e path appliance;
- [ ] configurare Wazuh FIM;
- [ ] verificare actor, hash e timestamp.

## Step 7 - Dataset sintetico

Creare esclusivamente dati fittizi:

- documenti legali e professionali;
- copie browser sintetiche;
- wallet inventory fittizio;
- identity events statici;
- nessuna password, token, wallet o account reale.

## Step 8 - Smoke test completo

La pipeline HTTP/JSONL isolata è validata. Restano:

1. process creation Windows;
2. file marker;
3. richiesta heartbeat dal nodo Windows;
4. eventi endpoint e rete nel dashboard;
5. cleanup del marker;
6. test negativi;
7. ripetizione dopo rollback.

## Step 9 - Snapshot finale

- [x] snapshot `SINKHOLE-READY`.
- [x] snapshot intermedio `WAZUH-READY`.
- [x] snapshot `WAZUH-PIPELINE-READY` dopo isolamento e verifica della configurazione corrente.
- [ ] eseguire checklist baseline multi-sorgente end-to-end.
- [ ] creare `LOGGING-READY`.
- [ ] creare `LOGGING-READY-LINUX`.
- [ ] registrare hash delle configurazioni finali.

## Definition of Done

La fase ambiente sarà `VALIDATED` quando:

- tutte le VM principali sono create e isolate;
- ogni agent è online;
- i campi chiave sono visibili;
- sinkhole, endpoint e appliance inviano telemetria;
- il test è ripetibile dopo rollback;
- le raw evidence restano private;
- cleanup e controllo baseline risultano completi.
