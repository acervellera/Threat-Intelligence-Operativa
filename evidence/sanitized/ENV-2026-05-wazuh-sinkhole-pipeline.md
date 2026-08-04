# ENV-2026-05 — Pipeline Wazuh ↔ sinkhole isolata

**Classificazione:** SANITIZED  
**Data:** 2026-08-04 UTC  
**Fasi:** STEP-02, STEP-03 e STEP-04 parziale  
**Esito:** PASS per la pipeline Linux/JSONL isolata; `LOGGING-READY` non ancora raggiunto

## Obiettivo

Validare una prima pipeline di telemetria end-to-end interamente interna alla rete LAB e dimostrare che continua a funzionare dopo la rimozione della NAT da entrambi i nodi:

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
- snapshot `CLEAN-OS` e `WAZUH-READY` creati a VM spenta;
- NIC NAT rimossa dalla configurazione persistente;
- dopo il riavvio resta soltanto `10.10.10.40/24` su `lab-lan`;
- default route e indirizzo NAT assenti;
- raggiungibilità interna verso host LAB e SINKHOLE-LAB confermata;
- accesso a `packages.wazuh.com` fallito come previsto per assenza di DNS/egress;
- snapshot `WAZUH-PIPELINE-READY` creato a VM spenta dopo la validazione isolata.

## Registrazione dell'agent sinkhole

L'agent `sinkhole-lab` è stato registrato sul manager e verificato come `Active`.

Dopo la rimozione della NIC NAT da SINKHOLE-LAB:

- resta soltanto `10.10.10.30/24` su `lab-lan`;
- non esiste una default route;
- WAZUH-LAB è raggiungibile sulla rete LAB;
- l'agent si connette a `10.10.10.40:1514/tcp`;
- heartbeat, inventario e SCA Debian sono stati avviati correttamente.

Dopo l'isolamento e il riavvio di WAZUH-LAB, l'agent è rimasto `Active`. Questo dimostra che il canale agent-manager non dipende dalla rete NAT.

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

## Test end-to-end isolato

Dopo la rimozione della NAT da WAZUH-LAB sono state generate tre richieste benigne dalla rete LAB:

| Test | Metodo e path | Risposta | Alert atteso |
|---|---|---:|---:|
| heartbeat | `GET /heartbeat` | 200 | `100101` |
| percorso inesistente | `GET /tio-isolated-not-found` | 404 | `100102` |
| metodo non consentito | `POST /tio-isolated-post` | 405 | `100103` |

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

## Stato temporale

Le VM usano UTC per la timeline. Dopo la rimozione della NAT, `systemd-timesyncd` resta attivo ma non risulta sincronizzato con un server esterno. L'ora UTC osservata era coerente con l'ora locale dell'host, considerando il fuso estivo UTC+2. Una sorgente NTP interna resta da configurare.

## Snapshot

| Snapshot | Significato |
|---|---|
| `CLEAN-OS` | Ubuntu pulito prima dell'installazione Wazuh |
| `WAZUH-READY` | Wazuh all-in-one installato e validato prima dell'integrazione finale |
| `WAZUH-PIPELINE-READY` | NAT rimossa, agent Active, JSONL acquisito, regole 100101-100103 e pipeline isolata validate |

Gli snapshot sono checkpoint interni dell'ambiente virtuale e non sostituiscono un backup indipendente.

## Limiti e attività residue

Questo checkpoint non equivale a `LOGGING-READY`:

- WIN11-LAB, Sysmon, PowerShell logging e auditing Windows non sono ancora disponibili;
- APPLIANCE-LAB, auditd e FIM non sono ancora disponibili;
- dataset sintetico e smoke test multi-sorgente non sono ancora completati;
- manca la ripetizione della pipeline dopo ripristino dello snapshot;
- mancano test negativi formali e misurazione delle metriche di detection;
- manca una sorgente NTP interna per i nodi senza egress;
- la retention finale del laboratorio non è ancora definita.

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
