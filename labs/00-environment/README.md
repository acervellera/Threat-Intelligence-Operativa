# 00 - Costruzione e validazione dell'ambiente

**Stato:** IN PROGRESS

## Obiettivo

Arrivare a una baseline ripetibile da cui iniziano tutti i casi.

## Checkpoint completato - SINKHOLE-LAB

Il checkpoint sanificato `ENV-2026-03` documenta una VM Debian isolata e ripristinabile:

- [x] 2 vCPU e 2 GiB RAM.
- [x] IP statico `10.10.10.30/24`.
- [x] Collegamento finale esclusivamente a `lab-lan`.
- [x] Nessuna default route e nessun accesso Internet.
- [x] SSH, Python 3, `curl`, `jq`, QEMU Guest Agent e SPICE Guest Agent.
- [x] Directory `/opt/tio-sinkhole` e `/var/log/tio-sinkhole` con permessi `0750`.
- [x] Snapshot `CLEAN-OS` creato a VM spenta.

Evidenza pubblica: [`evidence/sanitized/ENV-2026-03-sinkhole-baseline.md`](../../evidence/sanitized/ENV-2026-03-sinkhole-baseline.md).

Configurazione di rete sanificata: [`configs/libvirt/lab-lan.sanitized.xml`](../../configs/libvirt/lab-lan.sanitized.xml).

## Step 1 - Hypervisor e VM

- [x] Installare hypervisor con snapshot.
- [ ] Creare WIN11-LAB: 2 vCPU, 8 GB RAM, 80 GB.
- [x] Creare SINKHOLE-LAB: Ubuntu/Debian con Python 3.
- [ ] Creare WAZUH-LAB: 4 vCPU, 8-12 GB RAM.
- [ ] Creare APPLIANCE-LAB: 2 vCPU, 2-4 GB RAM.
- [ ] Creare ANALYST-LAB opzionale.
- [ ] Aggiornare tutti i sistemi e creare snapshot `CLEAN-OS`.

## Step 2 - Rete

- [x] Creare host-only `10.10.10.0/24`.
- [ ] Assegnare IP a tutte le VM secondo la topologia.
- [x] Verificare assenza di bridge verso LAN reale.
- [x] Usare NAT solo per patching.
- [x] Disabilitare NAT prima del test su SINKHOLE-LAB.
- [x] Applicare egress deny su SINKHOLE-LAB.
- [ ] Sincronizzare clock e annotare fuso su tutte le VM.

## Step 3 - Wazuh

- [ ] Installare Wazuh all-in-one.
- [ ] Registrare agent Windows e Linux.
- [ ] Verificare heartbeat e inventario.
- [ ] Definire retention di laboratorio.

## Step 4 - Windows telemetry

- [ ] Installare Sysmon e applicare configurazione LAB.
- [ ] Abilitare Microsoft-Windows-PowerShell/Operational.
- [ ] Abilitare Script Block Logging 4104.
- [ ] Abilitare TaskScheduler/Operational.
- [ ] Abilitare Security 4698/4699.
- [ ] Configurare Wazuh EventChannel.

## Step 5 - Linux telemetry

- [ ] Installare auditd.
- [ ] Configurare audit rules per execve, systemd e path appliance.
- [ ] Configurare Wazuh FIM.
- [ ] Verificare actor, hash e timestamp.

## Step 6 - Dataset sintetico

Creare esclusivamente dati fittizi:

- documenti legali e professionali;
- copie browser sintetiche;
- wallet inventory fittizio;
- identity events statici;
- nessuna password, token, wallet o account reale.

## Step 7 - Sinkhole

- [ ] Avviare server HTTP interno su `10.10.10.30:8080`.
- [ ] Verificare endpoint `/heartbeat` da WIN11-LAB.
- [ ] Verificare logging JSONL.
- [ ] Verificare che il server non esegua upload e non accetti comandi.

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

- ogni agent è online;
- i campi chiave sono visibili;
- sinkhole e Wazuh ricevono l'evento;
- test è ripetibile dopo rollback;
- raw evidence resta privata;
- cleanup completo.
