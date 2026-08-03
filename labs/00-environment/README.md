# 00 - Costruzione e validazione dell'ambiente

**Stato:** IN PROGRESS  
**Fase attiva:** STEP-02 — Rete e VM  
**Ultimo checkpoint:** `ENV-2026-03 — SINKHOLE-LAB CLEAN-OS`  
**Prossimo checkpoint:** servizio sinkhole HTTP su `10.10.10.30:8080`

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
| WIN11-LAB | `10.10.10.20` | NOT STARTED | - |
| SINKHOLE-LAB | `10.10.10.30` | CLEAN-OS READY | `CLEAN-OS` |
| WAZUH-LAB | `10.10.10.40` | NOT STARTED | - |
| APPLIANCE-LAB | `10.10.10.50` | NOT STARTED | - |
| ANALYST-LAB | `10.10.10.60` | OPTIONAL | - |

## Checkpoint completato - SINKHOLE-LAB

Il checkpoint sanificato `ENV-2026-03` documenta una VM Debian isolata e ripristinabile:

- [x] 2 vCPU e 2 GiB RAM.
- [x] Debian 13 amd64 aggiornato.
- [x] Hostname `sinkhole-lab` e dominio LAB `lab.internal`.
- [x] IP statico `10.10.10.30/24`.
- [x] Collegamento finale esclusivamente a `lab-lan`.
- [x] Nessuna default route e nessun accesso Internet.
- [x] SSH, Python 3, `curl`, `jq`, QEMU Guest Agent e SPICE Guest Agent.
- [x] Directory `/opt/tio-sinkhole` e `/var/log/tio-sinkhole` con permessi `0750`.
- [x] Snapshot `CLEAN-OS` creato a VM spenta.
- [x] Evidenza pubblica sanificata.
- [x] Configurazione libvirt ridotta e priva di identificatori locali.

Evidenza pubblica: [`evidence/sanitized/ENV-2026-03-sinkhole-baseline.md`](../../evidence/sanitized/ENV-2026-03-sinkhole-baseline.md).

Configurazione di rete sanificata: [`configs/libvirt/lab-lan.sanitized.xml`](../../configs/libvirt/lab-lan.sanitized.xml).

Issue di riferimento: `#3 — Costruire rete host-only e macchine virtuali`.

## Step 1 - Hypervisor e VM

- [x] Installare hypervisor con supporto snapshot.
- [ ] Creare WIN11-LAB: 2 vCPU, 8 GB RAM, 80 GB.
- [x] Creare SINKHOLE-LAB: Debian con Python 3.
- [ ] Creare WAZUH-LAB: 4 vCPU, 8-12 GB RAM.
- [ ] Creare APPLIANCE-LAB: 2 vCPU, 2-4 GB RAM.
- [ ] Creare ANALYST-LAB opzionale.
- [ ] Aggiornare tutti i sistemi e creare snapshot `CLEAN-OS`.

## Step 2 - Rete

- [x] Creare host-only `10.10.10.0/24`.
- [ ] Assegnare IP a tutte le VM secondo la topologia.
- [x] Verificare assenza di bridge verso LAN reale.
- [x] Usare NAT soltanto per installazione e patching.
- [x] Disabilitare NAT prima del test su SINKHOLE-LAB.
- [x] Applicare egress deny su SINKHOLE-LAB.
- [x] Usare UTC su SINKHOLE-LAB.
- [ ] Estendere isolamento, egress deny e UTC a tutte le VM.

## Step 3 - Sinkhole HTTP

Questo è il prossimo passaggio operativo.

- [ ] Creare applicazione HTTP benigna in `/opt/tio-sinkhole`.
- [ ] Esporre `10.10.10.30:8080`.
- [ ] Implementare endpoint `/heartbeat`.
- [ ] Scrivere log JSONL in `/var/log/tio-sinkhole`.
- [ ] Creare utente di servizio dedicato.
- [ ] Creare unità `systemd` con hardening minimo.
- [ ] Verificare avvio automatico e restart controllato.
- [ ] Verificare che non accetti comandi o esegua contenuti ricevuti.
- [ ] Pubblicare script e unità soltanto dopo test e sanificazione.

## Step 4 - Wazuh

- [ ] Installare Wazuh all-in-one.
- [ ] Registrare agent Windows e Linux.
- [ ] Verificare heartbeat e inventario.
- [ ] Definire retention di laboratorio.

## Step 5 - Windows telemetry

- [ ] Installare Sysmon e applicare configurazione LAB.
- [ ] Abilitare Microsoft-Windows-PowerShell/Operational.
- [ ] Abilitare Script Block Logging 4104.
- [ ] Abilitare TaskScheduler/Operational.
- [ ] Abilitare Security 4698/4699.
- [ ] Configurare Wazuh EventChannel.

## Step 6 - Linux telemetry

- [ ] Installare auditd.
- [ ] Configurare audit rules per execve, systemd e path appliance.
- [ ] Configurare Wazuh FIM.
- [ ] Verificare actor, hash e timestamp.

## Step 7 - Dataset sintetico

Creare esclusivamente dati fittizi:

- documenti legali e professionali;
- copie browser sintetiche;
- wallet inventory fittizio;
- identity events statici;
- nessuna password, token, wallet o account reale.

## Step 8 - Smoke test

Generare:

1. process creation;
2. file marker;
3. richiesta heartbeat;
4. evento nel dashboard;
5. cleanup del marker.

## Step 9 - Snapshot finale

- [ ] Eseguire checklist baseline.
- [ ] Creare `LOGGING-READY`.
- [ ] Creare `LOGGING-READY-LINUX`.
- [ ] Registrare hash delle configurazioni.

## Definition of Done

La fase ambiente sarà `VALIDATED` quando:

- tutte le VM principali sono create e isolate;
- ogni agent è online;
- i campi chiave sono visibili;
- sinkhole e Wazuh ricevono l'evento;
- il test è ripetibile dopo rollback;
- le raw evidence restano private;
- cleanup e controllo baseline risultano completi.
