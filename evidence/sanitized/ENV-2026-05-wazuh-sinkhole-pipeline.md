# ENV-2026-05 — Pipeline Wazuh ↔ sinkhole

**Classificazione:** SANITIZED  
**Data:** 2026-08-04 UTC  
**Fasi:** STEP-02, STEP-03 e STEP-04 parziale  
**Esito:** PASS per la pipeline Linux/JSONL; `LOGGING-READY` non ancora raggiunto

## Obiettivo

Validare una prima pipeline di telemetria end-to-end interamente interna alla rete LAB:

```text
richiesta HTTP controllata
  -> SINKHOLE-LAB
  -> requests.jsonl
  -> Wazuh Agent
  -> Wazuh Manager
  -> regola custom
  -> alerts.json
  -> Filebeat / Wazuh Indexer
  -> Wazuh Dashboard
```

## Ambiente sanificato

| Componente | Valore |
|---|---|
| WAZUH-LAB | Ubuntu Server 24.04 LTS, `10.10.10.40/24` |
| FQDN WAZUH-LAB | `wazuh-lab.lab.internal` |
| Risorse WAZUH-LAB | 4 vCPU, circa 8 GiB RAM, filesystem root circa 77 GiB |
| SINKHOLE-LAB | Debian 13, `10.10.10.30/24` |
| Rete | `lab-lan`, `10.10.10.0/24`, senza forwarding |
| Sorgente log | `/var/log/tio-sinkhole/requests.jsonl` |
| Agent Linux | Wazuh Agent v4.14.7 |

UUID, MAC address, credenziali, password dell'indexer, percorsi dell'host e log completi sono esclusi.

## Checkpoint WAZUH-LAB

- Ubuntu Server installato e aggiornato;
- IP statico `10.10.10.40/24` su `lab-lan`;
- hostname e FQDN validati;
- filesystem LVM esteso da circa 39 GiB a circa 78 GiB;
- servizi `wazuh-indexer`, `wazuh-manager`, `filebeat` e `wazuh-dashboard` attivi e abilitati;
- dashboard HTTPS raggiungibile con risposta HTTP 302;
- indexer con cluster health `green`, un nodo, zero shard non assegnati e 100% shard attivi;
- snapshot `CLEAN-OS` e `WAZUH-READY` creati a VM spenta.

## Registrazione dell'agent sinkhole

L'agent `sinkhole-lab` è stato registrato sul manager e verificato come `Active`.

Dopo la rimozione della NIC NAT da SINKHOLE-LAB:

- resta soltanto `10.10.10.30/24` su `lab-lan`;
- non esiste una default route;
- WAZUH-LAB è raggiungibile sulla rete LAB;
- l'agent si connette a `10.10.10.40:1514/tcp`;
- heartbeat, inventario e SCA Debian sono stati avviati correttamente.

Questo dimostra che il canale agent-manager non dipende dalla rete NAT.

## Raccolta JSONL

L'agent segue il file con una sezione `<localfile>` in formato JSON e aggiunge due label:

```text
@source = tio-sinkhole
lab.role = sinkhole
```

La validazione di `wazuh-logcollector` è terminata senza errori. Dopo il riavvio dell'agent, il log interno ha confermato:

```text
Analyzing file: '/var/log/tio-sinkhole/requests.jsonl'
```

La rotazione giornaliera del file resta attiva. Il servizio sinkhole apre il file in append per ogni richiesta e continua a scrivere nel nuovo file creato da logrotate.

## Regole custom validate

| Rule ID | Livello | Condizione |
|---:|---:|---|
| `100100` | 0 | raggruppamento di eventi JSON provenienti da `requests.jsonl` |
| `100101` | 3 | `status=200` e `path=/heartbeat` |
| `100102` | 5 | `status=404` |
| `100103` | 7 | `status=405` |

Nota tecnica: `status` è un campo statico del motore Wazuh ed è stato confrontato con il tag `<status>`, non con `<field name="status">`.

I controlli eseguiti hanno incluso:

- assenza di conflitti sugli ID;
- validazione con `wazuh-analysisd -t`;
- test con `wazuh-logtest` per 200, 404 e 405;
- riavvio controllato del manager;
- verifica dei servizi dopo il riavvio.

## Test end-to-end

Sono state generate tre richieste benigne dalla rete LAB:

| Test | Metodo e path | Risposta | Alert atteso |
|---|---|---:|---:|
| heartbeat | `GET /heartbeat` | 200 | `100101` |
| percorso inesistente | `GET /tio-live-not-found` | 404 | `100102` |
| metodo non consentito | `POST /tio-live-post` | 405 | `100103` |

I tre eventi sono stati:

- scritti nel JSONL con timestamp UTC, client IP, metodo, path, user agent e status;
- raccolti dall'agent;
- analizzati dal manager;
- trasformati in alert;
- inoltrati da Filebeat;
- indicizzati;
- ricercati nel dashboard mediante `rule.id`.

Query DQL utilizzata nel campo Search del Threat Hunting:

```text
rule.id:100101 or rule.id:100102 or rule.id:100103
```

## Limiti e attività residue

Questo checkpoint non equivale a `LOGGING-READY`:

- la NIC NAT di WAZUH-LAB è ancora temporaneamente presente;
- lo snapshot `WAZUH-READY` precede la configurazione finale di ingestione e delle regole;
- WIN11-LAB, Sysmon, PowerShell logging e auditing Windows non sono ancora disponibili;
- APPLIANCE-LAB, auditd e FIM non sono ancora disponibili;
- dataset sintetico e smoke test multi-sorgente non sono ancora completati;
- manca la ripetizione della pipeline dopo rollback;
- mancano test negativi e misurazione formale delle metriche di detection.

## Artefatti pubblici collegati

- `configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml`
- `configs/wazuh/rules/tio_sinkhole_rules.xml`
- `docs/03-telemetry-baseline/README.md`
- `docs/04-detection-engineering/README.md`

## Sanificazione applicata

- rimosse credenziali e password;
- esclusi MAC, UUID e indirizzi NAT dinamici;
- esclusi log raw e output completi;
- mantenuti soltanto indirizzi e nomi appartenenti alla topologia pubblica del laboratorio;
- nessun dato personale, aziendale o operativo reale incluso.
