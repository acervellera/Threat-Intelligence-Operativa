# Configurazioni Wazuh validate

Questa directory contiene copie pubbliche e ridotte delle configurazioni validate nel laboratorio. Non include password, certificati privati, chiavi agent, UUID, MAC address o output raw.

## Stato

| Area | File | Stato | Checkpoint |
|---|---|---|---|
| Agent Linux | [`linux-localfile/tio-sinkhole-jsonl.xml`](linux-localfile/tio-sinkhole-jsonl.xml) | VALIDATED | `ENV-2026-05` |
| Regole manager | [`rules/tio_sinkhole_rules.xml`](rules/tio_sinkhole_rules.xml) | VALIDATED | `ENV-2026-05` |
| EventChannel Windows | `windows-eventchannel/` | NOT STARTED | attende WIN11-LAB |

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

Verifica:

```bash
grep -F 'requests.jsonl' /var/ossec/logs/ossec.log | tail
```

Risultato atteso:

```text
Analyzing file: '/var/log/tio-sinkhole/requests.jsonl'
```

## Manager: regole sinkhole

Copiare il file delle regole nel manager:

```bash
install -o root -g wazuh -m 0640 \
  tio_sinkhole_rules.xml \
  /var/ossec/etc/rules/tio_sinkhole_rules.xml
```

Validare prima di riavviare:

```bash
/var/ossec/bin/wazuh-analysisd -t
```

Le regole pubblicate sono:

| ID | Livello | Scopo |
|---:|---:|---|
| `100100` | 0 | regola padre per JSON provenienti da `requests.jsonl` |
| `100101` | 3 | heartbeat HTTP 200 su `/heartbeat` |
| `100102` | 5 | richiesta con risposta HTTP 404 |
| `100103` | 7 | metodo non consentito con risposta HTTP 405 |

Dopo i test con `wazuh-logtest`:

```bash
systemctl restart wazuh-manager
systemctl is-active wazuh-manager
systemctl is-active filebeat
```

## Query dashboard

Nel campo **Search** del Threat Hunting usare:

```text
rule.id:100101 or rule.id:100102 or rule.id:100103
```

La query non deve essere inserita nel selettore **Field** della finestra `Add filter`.

## Rollback

Agent Linux:

1. ripristinare il backup di `/var/ossec/etc/ossec.conf`;
2. validare con `wazuh-logcollector -t` e `wazuh-agentd -t`;
3. riavviare `wazuh-agent`.

Manager:

1. rimuovere o ripristinare `/var/ossec/etc/rules/tio_sinkhole_rules.xml`;
2. validare con `wazuh-analysisd -t`;
3. riavviare `wazuh-manager`.

## Limiti

- Le tre regole dimostrano la pipeline e non costituiscono ancora un rule pack di produzione.
- Un singolo 404 o 405 non dimostra attività malevola.
- Mancano test negativi formali, tuning per frequenza e ripetizione dopo rollback.
- `LOGGING-READY` richiede ancora endpoint Windows, Sysmon, PowerShell, auditing e smoke test completo.

Evidenza collegata: [`../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`](../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md).
