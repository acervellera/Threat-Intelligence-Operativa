# Configurazioni Wazuh validate

Questa directory contiene copie pubbliche e ridotte delle configurazioni validate nel laboratorio. Non include password, certificati privati, chiavi agent, UUID, MAC address o output raw.

## Stato

| Area | File | Stato | Checkpoint |
|---|---|---|---|
| Agent Linux | [`linux-localfile/tio-sinkhole-jsonl.xml`](linux-localfile/tio-sinkhole-jsonl.xml) | VALIDATED | `ENV-2026-05` |
| Regole sinkhole | [`rules/tio_sinkhole_rules.xml`](rules/tio_sinkhole_rules.xml) | VALIDATED | `ENV-2026-05` |
| EventChannel Windows | [`windows-eventchannel/tio-windows-eventchannels.xml`](windows-eventchannel/tio-windows-eventchannels.xml) | VALIDATED | `ENV-2026-06` |
| Pipeline Linux/JSONL isolata | agent → manager → indexer → dashboard | VALIDATED | `WAZUH-PIPELINE-READY` |
| Pipeline multi-sorgente isolata | Windows + sinkhole → Wazuh → dashboard | VALIDATED per checkpoint | `ENV-2026-06` |

## Ambiente validato

- WAZUH-LAB: Ubuntu Server 24.04 LTS, `10.10.10.40/24`;
- Wazuh all-in-one 4.14.7;
- SINKHOLE-LAB: Debian 13, `10.10.10.30/24`;
- WIN11-LAB: Windows 11 Pro, `10.10.10.20/24`;
- rete `lab-lan` senza forwarding e senza default route sui nodi operativi;
- NTP interno tramite host `10.10.10.1`;
- snapshot `WAZUH-TELEMETRY-READY`, `SINKHOLE-TELEMETRY-READY` e `WIN11-TELEMETRY-READY`.

## Agent Linux: JSONL sinkhole

Il frammento `tio-sinkhole-jsonl.xml` configura `wazuh-logcollector` per seguire:

```text
/var/log/tio-sinkhole/requests.jsonl
```

Il formato è `json` e vengono aggiunte le label:

```text
@source = tio-sinkhole
lab.role = sinkhole
```

Installazione controllata sull'agent:

```bash
cp -a /var/ossec/etc/ossec.conf \
  "/root/ossec.conf.backup.$(date -u +%Y%m%dT%H%M%SZ)"

# Integrare il blocco XML una sola volta in ossec.conf.
/var/ossec/bin/wazuh-logcollector -t
/var/ossec/bin/wazuh-agentd -t
systemctl restart wazuh-agent
systemctl is-active wazuh-agent
```

## Agent Windows: EventChannel

Il frammento `tio-windows-eventchannels.xml` raccoglie soltanto gli eventi futuri dai canali:

- `Microsoft-Windows-Sysmon/Operational`;
- `Microsoft-Windows-PowerShell/Operational`;
- `Microsoft-Windows-TaskScheduler/Operational`.

Procedura applicata nel laboratorio:

1. backup di `ossec.conf`;
2. inserimento dei blocchi `<localfile>` una sola volta;
3. validazione XML con PowerShell;
4. riavvio controllato di `wazuhsvc`;
5. conferma nel log agent delle righe `Analyzing event log`;
6. verifica degli alert nel manager e in Threat Hunting.

I log `Application`, `Security` e `System` erano già acquisiti dall'installazione dell'agent. L'auditing Task Scheduler `4698/4699` è stato abilitato separatamente tramite policy Windows.

## Regole validate

### Sinkhole

| ID | Livello | Scopo |
|---:|---:|---|
| `100100` | 0 | regola padre per JSON provenienti da `requests.jsonl` |
| `100101` | 3 | heartbeat HTTP 200 su `/heartbeat` |
| `100102` | 5 | richiesta con risposta HTTP 404 |
| `100103` | 7 | metodo non consentito con risposta HTTP 405 |

### Windows

| ID | Livello | Scopo |
|---:|---:|---|
| `109910` | 5 | marker PowerShell Script Block Logging, Event ID 4104 |

La regola `109910` è stata validata con `wazuh-analysisd -t` e con un evento reale proveniente da WIN11-LAB. L'XML manager completo resta nello storage privato finché non termina la revisione dedicata del rule pack Windows.

## Test multi-sorgente validato

Dopo la rimozione della NIC NAT da WIN11-LAB sono stati osservati:

- Sysmon Event ID `1`, rule `92004`;
- PowerShell Event ID `4104`, rule `109910`;
- Task Scheduler Event ID `106`, rule `67014`;
- Security Event ID `4698`, rule `60228`;
- Task Scheduler Event ID `141`, rule `67015`;
- richiesta dal nodo Windows verso `/final-natless-check`, HTTP 404, rule `100102`.

Gli alert sono stati verificati sia in `alerts.json` sia nel dashboard Wazuh.

## Query dashboard

PowerShell marker:

```text
agent.id:"002" AND rule.id:"109910"
```

Task Scheduler:

```text
agent.id:"002" AND (rule.id:"67014" OR rule.id:"67015" OR rule.id:"60228")
```

Sinkhole:

```text
agent.id:"001" AND data.path:"/final-natless-check"
```

## Validazione e rollback

Manager:

```bash
/var/ossec/bin/wazuh-analysisd -t
systemctl restart wazuh-manager
```

Agent Windows:

1. ripristinare il backup di `ossec.conf`;
2. validare l'XML;
3. riavviare `wazuhsvc`;
4. verificare `ossec.log` e lo stato Active dell'agent.

Agent Linux:

1. ripristinare il backup di `/var/ossec/etc/ossec.conf`;
2. validare con `wazuh-logcollector -t` e `wazuh-agentd -t`;
3. riavviare `wazuh-agent`.

## Limiti

- Le regole pubblicate dimostrano la pipeline e non costituiscono un rule pack di produzione.
- Un singolo 404, 405 o marker di laboratorio non dimostra attività malevola.
- Mancano ancora appliance, auditd, FIM, retention finale, matrice TP/TN, metriche e ripetizione completa dopo rollback.
- `ENV-2026-06` non equivale a `LOGGING-READY`.

Evidenze collegate:

- [`../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`](../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md)
- [`../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md)
