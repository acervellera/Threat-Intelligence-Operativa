# 00 — Costruzione e validazione dell'ambiente

**Stato:** `IN PROGRESS`  
**Fase primaria:** `STEP-02 — Rete e VM`  
**Ultimo checkpoint:** `ENV-2026-06 — telemetria multi-sorgente isolata`  
**Prossimo checkpoint:** `APPLIANCE-LAB` su `10.10.10.50`

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
| APPLIANCE-LAB | `10.10.10.50` | NOT STARTED | - |
| ANALYST-LAB | `10.10.10.60` | OPTIONAL | - |

## Checkpoint verificati

### ENV-2026-03 — CLEAN-OS sinkhole

- Debian 13 aggiornato;
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

#### WIN11-LAB

- Windows 11 Pro su `10.10.10.20/24`;
- account amministrativo `labadmin` e account standard `labuser`;
- Wazuh Agent Active come agent `002`;
- Sysmon Operational acquisito;
- PowerShell Operational e Script Block Logging 4104;
- Task Scheduler Operational;
- auditing Security 4698/4699;
- dataset sintetico con manifesto SHA-256;
- test positivo e negativo Sysmon FileCreate;
- task come SYSTEM correlata con Sysmon;
- NIC NAT rimossa e zero default route;
- snapshot `WIN11-TELEMETRY-READY`.

#### NTP interno

- host Ubuntu con `chronyd`;
- listener NTP su `10.10.10.1:123/udp`;
- subnet autorizzata `10.10.10.0/24`;
- client `.20`, `.30` e `.40` osservati;
- timestamp UTC coerenti.

#### Smoke test NAT-less

- Sysmon Event ID `1`, rule `92004`;
- PowerShell Event ID `4104`, rule `109910`;
- Task Scheduler Event ID `106`, rule `67014`;
- Security Event ID `4698`, rule `60228`;
- Task Scheduler Event ID `141`, rule `67015`;
- richiesta WIN11-LAB → sinkhole `/final-natless-check`, HTTP 404, rule `100102`;
- alert verificati in CLI e Threat Hunting;
- cleanup completato.

#### Snapshot e pacchetti privati

- `WIN11-TELEMETRY-READY`;
- `WAZUH-TELEMETRY-READY`;
- `SINKHOLE-TELEMETRY-READY`;
- manifesti SHA-256 e metadati XML verificati e conservati privatamente.

Evidenza: [`ENV-2026-06-multisource-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md).

## Flusso validato

```text
WIN11-LAB
  | Sysmon / PowerShell / Task Scheduler / Security
  | Wazuh Agent TCP 1514
  v
WAZUH-LAB -> Manager -> alerts.json -> Filebeat -> Indexer -> Dashboard
  ^
  | Wazuh Agent TCP 1514
  |
SINKHOLE-LAB -> requests.jsonl
  ^
  | HTTP 8080
  |
WIN11-LAB
```

I tre nodi operativi usano esclusivamente `lab-lan` durante il checkpoint finale.

## Step 1 — Hypervisor e VM

- [x] Installare hypervisor con supporto snapshot.
- [x] Creare SINKHOLE-LAB.
- [x] Creare WAZUH-LAB.
- [x] Creare WIN11-LAB.
- [ ] Creare APPLIANCE-LAB.
- [ ] Creare ANALYST-LAB opzionale.

## Step 2 — Rete e tempo

- [x] Creare host-only `10.10.10.0/24`.
- [x] Verificare assenza di bridge verso LAN reale.
- [x] Rimuovere NAT da SINKHOLE-LAB.
- [x] Rimuovere NAT da WAZUH-LAB.
- [x] Rimuovere NAT-TEMP da WIN11-LAB.
- [x] Verificare zero default route sui tre nodi.
- [x] Configurare NTP interno su `10.10.10.1`.
- [x] Verificare client NTP `.20`, `.30`, `.40`.
- [ ] Estendere isolamento e NTP ad APPLIANCE-LAB.

## Step 3 — Sinkhole HTTP

- [x] applicazione HTTP benigna;
- [x] endpoint `/heartbeat`;
- [x] logging JSONL;
- [x] utente dedicato e hardening `systemd`;
- [x] rotazione e retention corrente;
- [x] health check;
- [x] invio del JSONL a Wazuh;
- [x] snapshot `SINKHOLE-TELEMETRY-READY`;
- [ ] ripetere il health check dopo rollback.

## Step 4 — Wazuh

- [x] installare Wazuh all-in-one;
- [x] registrare agent Linux e Windows;
- [x] acquisire JSONL ed EventChannel Windows;
- [x] validare regole sinkhole e marker Windows;
- [x] verificare dashboard e pipeline senza egress;
- [x] snapshot `WAZUH-TELEMETRY-READY`;
- [ ] definire retention finale;
- [ ] registrare agent appliance;
- [ ] ripetere la pipeline dopo rollback.

## Step 5 — Windows telemetry

- [x] installare WIN11-LAB;
- [x] installare Sysmon e applicare configurazione LAB;
- [x] abilitare PowerShell Operational e Script Block Logging 4104;
- [x] abilitare TaskScheduler/Operational;
- [x] abilitare Security 4698/4699;
- [x] configurare Wazuh EventChannel;
- [x] creare dataset sintetico e verificarne il manifesto;
- [x] eseguire test positivo e negativo FileCreate;
- [x] creare snapshot `WIN11-TELEMETRY-READY`.

## Step 6 — Linux appliance telemetry

- [ ] installare APPLIANCE-LAB;
- [ ] installare auditd;
- [ ] configurare regole per execve, systemd e path appliance;
- [ ] configurare Wazuh FIM;
- [ ] verificare actor, hash e timestamp.

## Step 7 — Smoke test completo

Completato per Windows + sinkhole + Wazuh:

- [x] process creation Windows;
- [x] file marker;
- [x] richiesta di rete dal nodo Windows;
- [x] eventi endpoint e rete nel dashboard;
- [x] cleanup del marker e delle task;
- [x] test negativo selettivo Sysmon;

Restano:

- [ ] telemetria appliance auditd/FIM;
- [ ] matrice formale TP/TN completa;
- [ ] metriche;
- [ ] ripetizione completa dopo rollback.

## Step 8 — Snapshot finali

- [x] `SINKHOLE-READY`;
- [x] `WAZUH-PIPELINE-READY`;
- [x] `WIN11-TELEMETRY-READY`;
- [x] `WAZUH-TELEMETRY-READY`;
- [x] `SINKHOLE-TELEMETRY-READY`;
- [ ] `LOGGING-READY`;
- [ ] `LOGGING-READY-LINUX`.

## Definition of Done

La fase ambiente sarà `VALIDATED` quando:

- tutte le VM principali sono create e isolate;
- ogni agent è online;
- i campi chiave sono visibili;
- sinkhole, endpoint e appliance inviano telemetria;
- il test è ripetibile dopo rollback;
- le raw evidence restano private;
- cleanup e controllo baseline risultano completi.

`ENV-2026-06` completa il checkpoint dei tre nodi principali già installati, ma non chiude la fase finché APPLIANCE-LAB resta assente.
