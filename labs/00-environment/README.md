# 00 - Costruzione e validazione dell'ambiente

**Stato:** IN PROGRESS  
**Fase primaria:** STEP-02 — Rete e VM  
**Ultimo checkpoint:** `ENV-2026-04 — SINKHOLE-READY`  
**Prossimo checkpoint:** `WAZUH-LAB` su `10.10.10.40`

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
| SINKHOLE-LAB | `10.10.10.30` | SINKHOLE-READY | `CLEAN-OS`, `SINKHOLE-READY` |
| WAZUH-LAB | `10.10.10.40` | NEXT | - |
| APPLIANCE-LAB | `10.10.10.50` | NOT STARTED | - |
| ANALYST-LAB | `10.10.10.60` | OPTIONAL | - |

## Checkpoint ENV-2026-03 — CLEAN-OS

Il primo checkpoint documenta una VM Debian isolata e ripristinabile:

- [x] 2 vCPU e 2 GiB RAM.
- [x] Debian 13 amd64 aggiornato.
- [x] Hostname `sinkhole-lab` e dominio LAB `lab.internal`.
- [x] IP statico `10.10.10.30/24`.
- [x] Collegamento finale esclusivamente a `lab-lan`.
- [x] Nessuna default route e nessun accesso Internet.
- [x] SSH, Python 3, `curl`, `jq`, QEMU Guest Agent e SPICE Guest Agent.
- [x] Directory `/opt/tio-sinkhole` e `/var/log/tio-sinkhole` con permessi `0750`.
- [x] Snapshot `CLEAN-OS` creato a VM spenta.

Evidenza: [`ENV-2026-03-sinkhole-baseline.md`](../../evidence/sanitized/ENV-2026-03-sinkhole-baseline.md).

Configurazione rete: [`lab-lan.sanitized.xml`](../../configs/libvirt/lab-lan.sanitized.xml).

## Checkpoint ENV-2026-04 — SINKHOLE-READY

Il secondo checkpoint aggiunge il servizio applicativo benigno:

- [x] utente di sistema dedicato `tio-sinkhole`;
- [x] servizio `systemd` attivo e abilitato;
- [x] listener esclusivo su `10.10.10.30:8080`;
- [x] assenza di listener globale `0.0.0.0:8080`;
- [x] endpoint `GET/HEAD /heartbeat`;
- [x] risposta positiva HTTP 200 e JSON valido;
- [x] risposta HTTP 404 per percorsi inesistenti;
- [x] rifiuto HTTP 405 per POST e metodi di modifica;
- [x] log JSONL in `/var/log/tio-sinkhole/requests.jsonl`;
- [x] campi `timestamp_utc`, `client_ip`, `method`, `path`, `query`, `user_agent`, `status`;
- [x] logrotate giornaliero, 14 archivi, compressione e `maxsize 10M`;
- [x] test dalla VM e dall'host `10.10.10.1`;
- [x] health check automatico con 16 controlli superati e 0 falliti;
- [x] isolamento confermato senza default route;
- [x] snapshot `SINKHOLE-READY` creato a VM spenta;
- [x] relazione snapshot `CLEAN-OS -> SINKHOLE-READY` verificata.

Evidenza: [`ENV-2026-04-sinkhole-ready.md`](../../evidence/sanitized/ENV-2026-04-sinkhole-ready.md).

Configurazioni e guida: [`configs/sinkhole`](../../configs/sinkhole/README.md).

Health check: [`scripts/common/tio-sinkhole-check.sh`](../../scripts/common/tio-sinkhole-check.sh).

## Flusso del servizio sinkhole

```text
client LAB
   |
   | HTTP verso 10.10.10.30:8080
   v
systemd -> python3 server.py -> risposta 200/404/405
                              |
                              v
                 requests.jsonl, un evento per riga
                              |
                              v
                 logrotate, 14 archivi compressi
```

Il programma apre il file JSONL in modalità append per ogni richiesta e lo chiude subito dopo. Per questo `logrotate` può rinominare il file attivo e crearne uno nuovo senza riavviare il servizio.

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

- [x] Creare applicazione HTTP benigna in `/opt/tio-sinkhole`.
- [x] Esporre esclusivamente `10.10.10.30:8080`.
- [x] Implementare endpoint `/heartbeat`.
- [x] Scrivere log JSONL in `/var/log/tio-sinkhole`.
- [x] Creare utente di servizio dedicato.
- [x] Creare unità `systemd` con hardening minimo.
- [x] Verificare avvio automatico.
- [x] Verificare che non accetti upload o comandi.
- [x] Configurare rotazione e retention dei log.
- [x] Pubblicare script, unità, health check ed evidenza sanificata.
- [ ] Ripetere il health check dopo rollback da `SINKHOLE-READY`.
- [ ] Inviare il JSONL a Wazuh.

## Step 4 - Wazuh

Questo è il prossimo passaggio operativo.

- [ ] Creare WAZUH-LAB con 4 vCPU e 8-12 GiB RAM.
- [ ] Configurare `10.10.10.40/24` sulla rete `lab-lan`.
- [ ] Installare Wazuh all-in-one usando NAT temporaneo.
- [ ] Rimuovere NAT dopo installazione e aggiornamento.
- [ ] Verificare egress deny.
- [ ] Registrare agent Windows e Linux.
- [ ] Acquisire il log JSONL del sinkhole.
- [ ] Verificare parsing dei campi e timestamp UTC.
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
5. cleanup del marker;
6. ripetizione dopo rollback.

Il test HTTP del sinkhole è pronto, ma lo smoke test completo resta bloccato finché Wazuh e gli endpoint non sono disponibili.

## Step 9 - Snapshot finale

- [x] Creare snapshot applicativo intermedio `SINKHOLE-READY`.
- [ ] Eseguire checklist baseline end-to-end.
- [ ] Creare `LOGGING-READY`.
- [ ] Creare `LOGGING-READY-LINUX`.
- [ ] Registrare hash delle configurazioni finali.

## Definition of Done

La fase ambiente sarà `VALIDATED` quando:

- tutte le VM principali sono create e isolate;
- ogni agent è online;
- i campi chiave sono visibili;
- sinkhole e Wazuh ricevono l'evento;
- il test è ripetibile dopo rollback;
- le raw evidence restano private;
- cleanup e controllo baseline risultano completi.
