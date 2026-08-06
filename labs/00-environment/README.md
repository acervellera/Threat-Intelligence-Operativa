# 00 — Costruzione e validazione dell'ambiente

**Stato:** `IN PROGRESS`  
**Fase primaria:** `STEP-02 — Rete e VM`  
**Ultimo checkpoint:** `ENV-2026-07 — APPLIANCE-LAB telemetry ready`  
**Prossimo checkpoint:** retention, matrice TP/TN e rollback coordinato

## Obiettivo

Arrivare a una baseline ripetibile da cui iniziano tutti i casi, mantenendo separate:

- installazione e patching tramite NAT temporaneo;
- comunicazione operativa sulla rete host-only;
- evidenze raw conservate nello storage privato;
- evidenze pubbliche ridotte e sanificate.

## Stato della topologia

| Nodo | IP | Stato | Snapshot |
|---|---|---|---|
| Host Ubuntu / `lab-lan` | `10.10.10.1` | bridge e NTP interno VALIDATED | n/a |
| WIN11-LAB | `10.10.10.20` | isolata, agent Active, telemetria Windows validata | `CLEAN-OS`, `WIN11-TELEMETRY-READY` |
| SINKHOLE-LAB | `10.10.10.30` | isolata, HTTP/JSONL e agent validati | `CLEAN-OS`, `SINKHOLE-READY`, `SINKHOLE-TELEMETRY-READY` |
| WAZUH-LAB | `10.10.10.40` | isolata, pipeline multi-sorgente validata | `CLEAN-OS`, `WAZUH-READY`, `WAZUH-PIPELINE-READY`, `WAZUH-TELEMETRY-READY` |
| APPLIANCE-LAB | `10.10.10.50` | isolata, auditd/FIM Whodata e agent validati | `CLEAN-OS`, `APPLIANCE-TELEMETRY-READY` |
| ANALYST-LAB | `10.10.10.60` | OPTIONAL | - |

## Checkpoint verificati

### ENV-2026-03 — CLEAN-OS sinkhole

- Debian 13 aggiornata;
- IP statico `10.10.10.30/24`;
- nessuna default route e nessun accesso Internet;
- snapshot `CLEAN-OS`.

Evidenza: [`ENV-2026-03-sinkhole-baseline.md`](../../evidence/sanitized/ENV-2026-03-sinkhole-baseline.md).

### ENV-2026-04 — SINKHOLE-READY

- servizio `systemd` non-root;
- listener su `10.10.10.30:8080`;
- endpoint `/heartbeat`;
- test HTTP 200, 404 e 405;
- JSONL, logrotate e health check 16 PASS / 0 FAIL;
- snapshot `SINKHOLE-READY`.

Evidenza: [`ENV-2026-04-sinkhole-ready.md`](../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md).

### ENV-2026-05 — Pipeline Wazuh ↔ sinkhole isolata

- WAZUH-LAB su Ubuntu Server 24.04 LTS;
- manager, indexer, dashboard e Filebeat attivi;
- cluster indexer green;
- agent `sinkhole-lab` Active;
- ingestione del JSONL;
- regole `100100`–`100103` validate;
- NAT rimossa da SINKHOLE-LAB e WAZUH-LAB;
- pipeline verificata dopo isolamento e riavvio;
- snapshot `WAZUH-PIPELINE-READY`.

Evidenza: [`ENV-2026-05-wazuh-sinkhole-pipeline.md`](../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md).

### ENV-2026-06 — Telemetria multi-sorgente isolata

- WIN11-LAB con Wazuh Agent `002`, Sysmon, PowerShell 4104, Task Scheduler e Security 4698/4699;
- dataset sintetico con manifesto SHA-256 e integrità 27/27;
- test positivo e negativo Sysmon FileCreate;
- NTP interno `10.10.10.1` per `.20`, `.30` e `.40`;
- NAT rimossa da WIN11-LAB;
- smoke test endpoint → Wazuh e endpoint → sinkhole;
- alert verificati in CLI e Threat Hunting;
- snapshot `WIN11-TELEMETRY-READY`, `WAZUH-TELEMETRY-READY` e `SINKHOLE-TELEMETRY-READY`.

Evidenza: [`ENV-2026-06-multisource-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md).

### ENV-2026-07 — APPLIANCE-TELEMETRY-READY

#### Baseline

- Ubuntu Server 24.04 LTS minimizzata;
- 2 vCPU, 2 GiB RAM e root LVM di circa 38 GiB;
- SSH, QEMU Guest Agent e timesyncd operativi;
- NTP interno `10.10.10.1`;
- snapshot `CLEAN-OS` creato prima della telemetria.

#### Auditd e Wazuh

- `auditd` e `audispd-plugins` installati;
- regole persistenti per script sintetico e unit systemd di prova;
- Wazuh Agent 4.14.7, agent `003`, Active;
- raccolta `/var/log/audit/audit.log`;
- mapping CDB `tio_appliance_exec:execute`;
- alert Audit rule `80789`.

#### FIM Whodata

- monitoraggio realtime di `/opt/tio-appliance-lab/data`;
- watch dinamica `wazuh_fim`;
- ciclo file added, modified, permissions changed e deleted;
- rules `554`, `550`, `553`;
- utente e processo attribuiti a `labadmin`;
- test negativo sotto `/var/tmp` con zero alert.

Una watch Audit personalizzata duplicata sul percorso FIM è stata rimossa; il ciclo è stato ripetuto con la sola watch `wazuh_fim` e ha superato tutti i controlli.

#### SCA, isolamento e snapshot

- `/etc/audit/plugins.d/af_wazuh.conf` corretto a `0640 root:root`;
- controlli SCA `35752` e `35754` passati da failed a passed;
- NIC NAT rimossa dalla configurazione persistente;
- assenza di default route e accesso Internet;
- NTP interno, Audit e Wazuh operativi in isolamento;
- bundle pre e post isolamento verificati;
- snapshot `APPLIANCE-TELEMETRY-READY` a VM spenta;
- riavvio, SSH e agent Active verificati.

Evidenza: [`ENV-2026-07-appliance-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md).

## Flusso validato

```text
WIN11-LAB
  -> Sysmon / PowerShell / Task Scheduler / Security
  -> Wazuh Agent 002
  -> WAZUH-LAB

SINKHOLE-LAB
  -> requests.jsonl
  -> Wazuh Agent 001
  -> WAZUH-LAB

APPLIANCE-LAB
  -> auditd / FIM Whodata
  -> Wazuh Agent 003
  -> WAZUH-LAB

WAZUH-LAB
  -> Manager -> alerts.json -> Filebeat -> Indexer -> Dashboard
```

I quattro nodi principali usano esclusivamente `lab-lan` durante i checkpoint finali.

## Step 1 — Hypervisor e VM

- [x] Installare hypervisor con supporto snapshot.
- [x] Creare SINKHOLE-LAB.
- [x] Creare WAZUH-LAB.
- [x] Creare WIN11-LAB.
- [x] Creare APPLIANCE-LAB.
- [ ] Creare ANALYST-LAB solo se necessaria.

## Step 2 — Rete e tempo

- [x] Creare host-only `10.10.10.0/24`.
- [x] Verificare assenza di bridge verso LAN reale.
- [x] Rimuovere NAT dai quattro nodi principali.
- [x] Verificare zero default route sui quattro nodi.
- [x] Configurare NTP interno su `10.10.10.1`.
- [x] Verificare client NTP `.20`, `.30`, `.40`, `.50`.

## Step 3 — Sinkhole HTTP

- [x] applicazione HTTP benigna;
- [x] endpoint `/heartbeat`;
- [x] logging JSONL;
- [x] utente dedicato e hardening `systemd`;
- [x] rotazione e health check;
- [x] invio JSONL a Wazuh;
- [x] snapshot `SINKHOLE-TELEMETRY-READY`;
- [ ] ripetere health check dopo rollback globale.

## Step 4 — Wazuh

- [x] installare Wazuh all-in-one;
- [x] registrare agent Linux e Windows;
- [x] acquisire JSONL, EventChannel Windows e Audit Linux;
- [x] validare regole sinkhole, marker Windows e audit execution;
- [x] verificare dashboard e pipeline senza egress;
- [x] snapshot `WAZUH-TELEMETRY-READY`;
- [ ] definire retention finale;
- [ ] ripetere pipeline dopo rollback globale.

## Step 5 — Windows telemetry

- [x] Sysmon, PowerShell 4104, Task Scheduler e Security 4698/4699;
- [x] Wazuh EventChannel;
- [x] dataset sintetico e manifesto;
- [x] test positivo e negativo FileCreate;
- [x] snapshot `WIN11-TELEMETRY-READY`.

## Step 6 — Linux appliance telemetry

- [x] installare APPLIANCE-LAB;
- [x] installare auditd;
- [x] configurare regole per esecuzione e systemd;
- [x] configurare Wazuh FIM Whodata;
- [x] verificare utente, processo, hash e timestamp;
- [x] eseguire test negativo;
- [x] rimuovere NAT e ripetere in isolamento;
- [x] creare `APPLIANCE-TELEMETRY-READY`.

## Step 7 — Smoke test completo

Completato per singolo nodo e per i checkpoint multi-sorgente:

- [x] process creation Windows;
- [x] file marker Windows;
- [x] richiesta di rete verso sinkhole;
- [x] Audit execution Linux;
- [x] FIM added/modified/deleted Whodata;
- [x] test negativi selettivi Sysmon e FIM;
- [x] cleanup degli artefatti temporanei;

Restano:

- [ ] matrice formale TP/TN completa;
- [ ] metriche;
- [ ] smoke test coordinato dei quattro nodi;
- [ ] ripetizione completa dopo rollback.

## Step 8 — Snapshot finali

- [x] `SINKHOLE-READY`;
- [x] `WAZUH-PIPELINE-READY`;
- [x] `WIN11-TELEMETRY-READY`;
- [x] `WAZUH-TELEMETRY-READY`;
- [x] `SINKHOLE-TELEMETRY-READY`;
- [x] `APPLIANCE-TELEMETRY-READY`;
- [ ] `LOGGING-READY`;
- [ ] `LOGGING-READY-LINUX`.

## Definition of Done

La fase ambiente sarà `VALIDATED` quando:

- tutte le VM principali sono create e isolate;
- ogni agent è online;
- i campi chiave sono visibili;
- sinkhole, endpoint e appliance inviano telemetria;
- retention e test matrix sono formalizzati;
- il test è ripetibile dopo rollback;
- le raw evidence restano private;
- cleanup e controllo baseline risultano completi.

`ENV-2026-07` completa il checkpoint del quarto nodo principale, ma non chiude la fase finché retention, metriche e rollback globale restano aperti.
