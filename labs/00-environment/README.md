# 00 - Costruzione e validazione dell'ambiente

**Stato:** NOT STARTED

## Obiettivo

Arrivare a una baseline ripetibile da cui iniziano tutti i casi.

## Step 1 - Hypervisor e VM

- [ ] Installare hypervisor con snapshot.
- [ ] Creare WIN11-LAB: 2 vCPU, 8 GB RAM, 80 GB.
- [ ] Creare SINKHOLE-LAB: Ubuntu/Debian con Python 3.
- [ ] Creare WAZUH-LAB: 4 vCPU, 8-12 GB RAM.
- [ ] Creare APPLIANCE-LAB: 2 vCPU, 2-4 GB RAM.
- [ ] Creare ANALYST-LAB opzionale.
- [ ] Aggiornare sistemi e creare snapshot `CLEAN-OS`.

## Step 2 - Rete

- [ ] Creare host-only `10.10.10.0/24`.
- [ ] Assegnare IP secondo la topologia.
- [ ] Verificare assenza di bridge verso LAN reale.
- [ ] Usare NAT solo per patching.
- [ ] Disabilitare NAT prima del test.
- [ ] Applicare egress deny.
- [ ] Sincronizzare clock e annotare fuso.

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
