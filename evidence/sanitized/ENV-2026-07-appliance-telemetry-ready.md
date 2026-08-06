# ENV-2026-07 — APPLIANCE-LAB telemetry ready

**Classificazione:** `SANITIZED`  
**Data:** `2026-08-06 UTC`  
**Fasi:** `STEP-02`, `STEP-03`, `STEP-04` parziali  
**Esito:** `PASS` per il nodo appliance; il laboratorio globale non è ancora `LOGGING-READY`

## Obiettivo

Aggiungere una quarta sorgente Linux isolata al laboratorio e verificare una pipeline ripetibile:

```text
operazione su APPLIANCE-LAB
  -> auditd oppure Wazuh FIM Whodata
  -> Wazuh Agent
  -> Wazuh Manager
  -> alerts.json
  -> Indexer e Dashboard
```

Il test usa esclusivamente script, file e unit systemd sintetici.

## Nodo validato

| Campo | Valore pubblico |
|---|---|
| VM | `APPLIANCE-LAB` |
| Sistema | Ubuntu Server 24.04 LTS minimizzato |
| IP LAB | `10.10.10.50/24` |
| Rete finale | sola `lab-lan`, nessuna default route |
| NTP | host LAB `10.10.10.1` |
| Wazuh Agent | 4.14.7, agent `003`, stato Active |
| Snapshot iniziale | `CLEAN-OS` |
| Snapshot finale | `APPLIANCE-TELEMETRY-READY` |

La NIC NAT è stata usata soltanto per patching e installazione, poi rimossa dalla definizione persistente della VM.

## Baseline del sistema

Prima della telemetria sono stati verificati:

- hostname e FQDN di laboratorio;
- filesystem root LVM esteso a circa 38 GiB;
- memoria e swap disponibili;
- SSH e QEMU Guest Agent attivi;
- sincronizzazione UTC tramite `10.10.10.1`;
- assenza di riavvio pendente;
- snapshot `CLEAN-OS` creato a VM spenta;
- metadati e manifesti SHA-256 conservati nello storage privato.

## Auditd

Sono stati installati `auditd` e `audispd-plugins` e verificati:

- servizio `auditd` active/enabled;
- file `/var/log/audit/audit.log` presente;
- sottosistema kernel audit attivo;
- `lost=0` durante i checkpoint;
- marker benigno inserito e ritrovato con `ausearch`.

### Regole TIO persistenti

La configurazione pubblica finale monitora:

```text
tio_appliance_exec      esecuzione dello script sintetico
tio_systemd_changes     modifiche alla unit systemd di prova
```

La watch personalizzata inizialmente applicata alla directory FIM è stata rimossa, perché sovrapponeva la watch dinamica `wazuh_fim` usata dal motore Whodata.

## Wazuh Agent e audit log

Il Wazuh Agent è stato installato alla stessa versione del manager e mantenuto in hold. Sono stati verificati:

- enrollment sul manager interno `10.10.10.40`;
- traffico agent su `1514/tcp`;
- agent `003` Active;
- raccolta di `/var/log/audit/audit.log` con formato `audit`;
- mapping CDB `tio_appliance_exec:execute` sul manager;
- alert rule `80789` per l'esecuzione dello script sintetico.

Il test Audit isolato ha conservato i campi di attribuzione, tra cui chiave, successo, comando, executable, `auid`, `uid`, working directory e argomento marker.

## Wazuh FIM Whodata

Il percorso sintetico monitorato è:

```text
/opt/tio-appliance-lab/data
```

Opzioni validate:

```text
check_all=yes
realtime=yes
whodata=yes
report_changes=yes
```

Wazuh ha creato la watch dinamica:

```text
-w /opt/tio-appliance-lab/data -p wa -k wazuh_fim
```

Il ciclo positivo ha prodotto:

| Operazione | Rule ID | Evento | Modalità |
|---|---:|---|---|
| creazione file | `554` | `added` | `whodata` |
| modifica contenuto | `550` | `modified` | `whodata` |
| modifica permessi | `550` | `modified` | `whodata` |
| cancellazione | `553` | `deleted` | `whodata` |

Per tutti gli eventi sono stati osservati attribuzione all'utente sintetico `labadmin`, processo responsabile e metadati di integrità. Il test negativo sotto `/var/tmp` ha prodotto zero alert FIM per il percorso TIO.

## Correzione della sovrapposizione Audit/FIM

Durante il primo test il percorso dati aveva due watch con chiavi differenti:

```text
tio_appliance_files
wazuh_fim
```

Gli eventi venivano associati alla watch personalizzata e non alimentavano correttamente Whodata. La correzione applicata è stata:

1. backup della configurazione Audit;
2. rimozione della sola watch `tio_appliance_files` dal percorso FIM;
3. ricaricamento con `augenrules`;
4. riavvio controllato del Wazuh Agent;
5. conferma della sola watch dinamica `wazuh_fim`;
6. ripetizione del ciclo added/modified/deleted.

## Security Configuration Assessment

L'attivazione Whodata ha generato `/etc/audit/plugins.d/af_wazuh.conf` con metadati non conformi ai controlli CIS Ubuntu 24.04:

- `35752` — modalità dei file di configurazione Audit;
- `35754` — gruppo dei file di configurazione Audit.

La correzione controllata ha impostato:

```text
mode=0640
owner=root
group=root
```

Dopo il riavvio dell'agent i metadati sono rimasti stabili, `auditd` e `wazuh-agent` sono rimasti active e la watch `wazuh_fim` è rimasta presente. Una nuova scansione SCA ha registrato entrambe le transizioni `failed -> passed` tramite rule `19010`.

## Test completamente isolato

Dopo la rimozione della NIC NAT sono stati verificati:

- sola interfaccia LAB con `10.10.10.50/24`;
- assenza di default route;
- accesso Internet non disponibile;
- NTP sincronizzato con `10.10.10.1`;
- `auditd`, `wazuh-agent`, SSH, QEMU Guest Agent e timesyncd attivi;
- manager interno raggiungibile sulle porte necessarie;
- agent `003` Active;
- nuovo alert Audit rule `80789`;
- nuovo ciclo FIM rules `550`, `553`, `554` in modalità Whodata;
- test negativo FIM con zero alert.

Il test dimostra che Audit, FIM, Whodata e la pipeline Wazuh operano senza egress Internet.

## Evidenze private

Sono stati creati e verificati bundle distinti:

- readiness pre-isolamento dell'appliance;
- alert e stato del manager;
- readiness post-isolamento dell'appliance;
- alert post-isolamento del manager;
- manifesti SHA-256 interni;
- metadati XML degli snapshot.

Il repository pubblico non contiene archivi raw, chiavi agent, MAC, UUID, percorsi dell'host o hash di bundle privati non distribuiti.

## Snapshot

Lo snapshot finale `APPLIANCE-TELEMETRY-READY` è stato creato a VM spenta, con parent `CLEAN-OS`. Dopo il riavvio sono stati ricontrollati SSH e stato Active dell'agent.

## Risultato

| Controllo | Esito |
|---|---|
| baseline e snapshot `CLEAN-OS` | PASS |
| auditd locale | PASS |
| Wazuh Agent `003` Active | PASS |
| audit execution rule `80789` | PASS |
| FIM added/modified/permissions/deleted | PASS |
| Whodata e attribuzione utente/processo | PASS |
| test negativo FIM | PASS |
| SCA `35752` e `35754` recovered | PASS |
| isolamento, assenza egress e NTP interno | PASS |
| snapshot `APPLIANCE-TELEMETRY-READY` | PASS |

## Limiti

Questo checkpoint completa la telemetria del singolo nodo appliance, ma non chiude il gate globale. Restano:

- retention finale del laboratorio;
- matrice formale TP/TN multi-nodo;
- metriche di latency, coverage, precision e data quality;
- ripetizione coordinata dopo rollback;
- inventario globale e snapshot `LOGGING-READY` / `LOGGING-READY-LINUX`.

## Configurazioni pubbliche collegate

- `configs/auditd/70-tio-appliance.rules`;
- `configs/wazuh/linux-fim/tio-appliance-fim.xml`;
- `configs/wazuh/lists/tio-audit-keys.txt`;
- `scripts/lab/tio-marker.sh`.
