# ENV-2026-06 — Telemetria multi-sorgente isolata

**Classificazione:** `SANITIZED`  
**Exercise ID:** `ENV-2026-06`  
**Data:** `2026-08-05 UTC`  
**Esito:** `PASS` per il checkpoint a tre nodi; `LOGGING-READY` globale non ancora raggiunto

## Obiettivo

Validare la telemetria multi-sorgente del nucleo del laboratorio dopo la rimozione delle interfacce NAT operative, usando esclusivamente la rete `lab-lan`:

- `WIN11-LAB` su `10.10.10.20`;
- `SINKHOLE-LAB` su `10.10.10.30`;
- `WAZUH-LAB` su `10.10.10.40`;
- host Ubuntu e server NTP interno su `10.10.10.1`.

Il checkpoint verifica isolamento, sincronizzazione temporale, raccolta Windows, pipeline sinkhole, visualizzazione nel dashboard, cleanup, integrità delle baseline e snapshot per singolo nodo.

## Stato della topologia

| Nodo | Stato verificato | Snapshot corrente |
|---|---|---|
| Host Ubuntu | bridge `lab-lan` e NTP interno attivi | n/a |
| WIN11-LAB | isolata, agent Active, telemetria Windows validata | `WIN11-TELEMETRY-READY` |
| SINKHOLE-LAB | isolata, servizio HTTP/JSONL e agent attivi | `SINKHOLE-TELEMETRY-READY` |
| WAZUH-LAB | isolata, manager/indexer/dashboard/Filebeat attivi | `WAZUH-TELEMETRY-READY` |
| APPLIANCE-LAB | non ancora installata | - |

Tutti e tre i nodi operativi sono privi di default route durante il test finale.

## Sincronizzazione temporale interna

L'host Ubuntu esegue `chronyd` come client verso sorgenti esterne e come server NTP esclusivamente su `10.10.10.1:123/udp` per `10.10.10.0/24`.

Verifiche completate:

- `WIN11-LAB` usa `10.10.10.1,0x8` tramite `W32Time`;
- `WAZUH-LAB` usa `10.10.10.1` tramite `systemd-timesyncd`;
- `SINKHOLE-LAB` usa `10.10.10.1` tramite `systemd-timesyncd`;
- `chronyc clients` ha mostrato richieste reali da `10.10.10.20`, `10.10.10.30` e `10.10.10.40`;
- i timestamp UTC dei nodi sono risultati coerenti.

## WIN11-LAB

### Baseline e isolamento

- Windows 11 Pro su rete esclusivamente `LAB-LAN`;
- indirizzo `10.10.10.20/24`;
- interfaccia NAT temporanea rimossa dalla configurazione persistente;
- zero route IPv4 predefinite;
- SSH, `Sysmon`, `W32Time` e `wazuhsvc` active/automatic;
- connettività interna verso `10.10.10.40:1514/tcp` e `10.10.10.30:8080/tcp` verificata;
- account standard `labuser` presente, abilitato e non amministratore.

### Raccolta Windows

Sorgenti EventChannel abilitate e acquisite dall'agent:

- `Microsoft-Windows-Sysmon/Operational`;
- `Microsoft-Windows-PowerShell/Operational`;
- `Microsoft-Windows-TaskScheduler/Operational`;
- log `Security`, inclusi gli eventi di auditing delle attività pianificate.

Telemetria verificata:

- Sysmon Event ID `1` — ProcessCreate;
- Sysmon Event ID `11` — FileCreate;
- Sysmon Event ID `3`, `13`, `15` e `22` durante i test locali;
- PowerShell Event ID `4104` — Script Block Logging;
- Task Scheduler Operational Event ID `106`, `110`, `129`, `100`, `200`, `201`, `102` e `141`;
- Security Event ID `4698` per la creazione di una task; auditing `4699` abilitato e verificato localmente.

### Test positivo e negativo Sysmon FileCreate

La configurazione Sysmon include il percorso `C:\Lab\`.

| Test | Percorso | Eventi Sysmon ID 11 | Esito |
|---|---|---:|---|
| positivo | `C:\Lab\Telemetry-Test\TIO-POSITIVE.txt` | 1 | PASS |
| negativo | percorso esterno ai path monitorati | 0 | PASS |

Il test dimostra selettività della raccolta: il file negativo è stato creato dal sistema, ma non incluso dalla regola Sysmon.

### Task Scheduler e correlazione

Una task temporanea eseguita come `SYSTEM` ha prodotto un marker in `C:\ProgramData\TIO`.

- ultimo esito task: `0`;
- Task Scheduler ha registrato avvio e completamento dell'azione;
- Sysmon ID `11` ha registrato lo stesso file creato da `cmd.exe` come `NT AUTHORITY\SYSTEM`;
- PID e timestamp hanno permesso la correlazione tra i due sensori;
- task e marker sono stati rimossi dopo il test.

### Dataset sintetico

È stata creata una baseline esclusivamente fittizia sotto `C:\Lab\Synthetic`:

- 27 file registrati nel manifesto;
- 28 file totali includendo `manifest-sha256.csv`;
- 20 documenti legali sintetici;
- documenti, browser profile fittizio, OneDrive simulato, identity e cloud manifest;
- nessun dato, account, token o documento reale.

Verifica di integrità:

| Controllo | Valore |
|---|---:|
| file previsti | 27 |
| file presenti | 27 |
| file invariati | 27 |
| modificati | 0 |
| mancanti | 0 |
| inattesi | 0 |
| integrità | PASS |

## Test end-to-end senza NAT

Il test finale è stato eseguito dopo la rimozione della NIC NAT da WIN11-LAB.

| Sorgente | Evento / regola | Evidenza osservata |
|---|---|---|
| WIN11-LAB / Sysmon | Event ID `1`, rule `92004` | processo `cmd.exe` con marker di test |
| WIN11-LAB / PowerShell | Event ID `4104`, rule `109910` | marker `TIO-WAZUH-4104-PIPELINE` |
| WIN11-LAB / Task Scheduler | Event ID `106`, rule `67014` | task `TIO-FINAL-NATLESS` registrata |
| WIN11-LAB / Security | Event ID `4698`, rule `60228` | task creata |
| WIN11-LAB / Task Scheduler | Event ID `141`, rule `67015` | task eliminata |
| SINKHOLE-LAB | rule `100102` | `GET /final-natless-check`, HTTP 404, origine `10.10.10.20` |

Gli alert sono stati verificati in `alerts.json` e nel modulo Threat Hunting del dashboard.

## SINKHOLE-LAB

Verifiche finali:

- servizio `tio-sinkhole` active/enabled;
- Wazuh Agent active/enabled;
- listener su `10.10.10.30:8080`;
- `GET /heartbeat` → HTTP 200;
- percorso sconosciuto → HTTP 404;
- metodo POST → HTTP 405;
- richieste registrate nel JSONL;
- NTP interno e assenza di default route;
- manifesto delle evidenze private verificato prima e dopo il trasferimento.

## WAZUH-LAB

Verifiche finali:

- `wazuh-manager`, `wazuh-indexer`, `filebeat` e `wazuh-dashboard` operativi;
- agent `sinkhole-lab` e `WIN11-LAB` Active;
- regole sinkhole `100100`–`100103` presenti e validate;
- regola Windows `109910` presente e validata;
- dashboard HTTPS raggiungibile dall'host Ubuntu sulla rete LAB;
- manifesto delle evidenze private verificato prima e dopo il trasferimento.

## Snapshot creati

Gli snapshot sono stati creati con le VM spente e verificati dopo il riavvio:

```text
WIN11-LAB
CLEAN-OS
  └── WIN11-TELEMETRY-READY

WAZUH-LAB
CLEAN-OS
  └── WAZUH-READY
      └── WAZUH-PIPELINE-READY
          └── WAZUH-TELEMETRY-READY

SINKHOLE-LAB
CLEAN-OS
  └── SINKHOLE-READY
      └── SINKHOLE-TELEMETRY-READY
```

I metadati XML e i relativi hash sono conservati nello storage privato. Gli snapshot QCOW2 non sono pubblicati e non sostituiscono un backup indipendente.

## Evidenze private e sanificazione

Sono stati creati pacchetti privati per WIN11-LAB, WAZUH-LAB e SINKHOLE-LAB con:

- timestamp UTC;
- stato servizi e rete;
- configurazioni o relativi hash;
- alert finali ridotti;
- manifesti SHA-256;
- verifica degli hash prima e dopo il trasferimento.

Il repository pubblico non contiene:

- credenziali e chiavi agent;
- UUID o MAC address;
- percorsi locali dell'host;
- log completi, EVTX, immagini disco o snapshot;
- output di inventario non sanificati;
- hash di archivi privati non distribuiti.

## Limiti e attività aperte

Questo checkpoint non equivale a `LOGGING-READY` globale. Restano:

- APPLIANCE-LAB su `10.10.10.50`;
- auditd e Wazuh FIM per la componente appliance/Linux;
- retention finale del laboratorio;
- matrice formale TP/TN e metriche di latency, coverage, precision e data quality;
- ripetizione completa dopo rollback dagli snapshot;
- snapshot globali `LOGGING-READY` e `LOGGING-READY-LINUX`.

## Conclusione

`ENV-2026-06` valida il nucleo multi-sorgente isolato del laboratorio: endpoint Windows, sinkhole e piattaforma Wazuh continuano a comunicare, sincronizzarsi e produrre alert ricercabili senza accesso Internet operativo. Le campagne restano bloccate fino al completamento della Definition of Done di `LOGGING-READY`.
