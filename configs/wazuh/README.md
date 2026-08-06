# Configurazioni Wazuh validate

Questa directory contiene copie pubbliche e ridotte delle configurazioni validate nel laboratorio. Non include password, certificati privati, chiavi agent, UUID, MAC address o output raw.

## Stato

| Area | File | Stato | Checkpoint |
|---|---|---|---|
| Agent Linux sinkhole | [`linux-localfile/tio-sinkhole-jsonl.xml`](linux-localfile/tio-sinkhole-jsonl.xml) | VALIDATED | `ENV-2026-05` |
| Regole sinkhole | [`rules/tio_sinkhole_rules.xml`](rules/tio_sinkhole_rules.xml) | VALIDATED | `ENV-2026-05` |
| EventChannel Windows | [`windows-eventchannel/tio-windows-eventchannels.xml`](windows-eventchannel/tio-windows-eventchannels.xml) | VALIDATED | `ENV-2026-06` |
| FIM Linux appliance | [`linux-fim/tio-appliance-fim.xml`](linux-fim/tio-appliance-fim.xml) | VALIDATED | `ENV-2026-07` |
| Audit key mapping | [`lists/tio-audit-keys.txt`](lists/tio-audit-keys.txt) | VALIDATED | `ENV-2026-07` |
| Pipeline Linux/JSONL isolata | agent → manager → indexer → dashboard | VALIDATED | `WAZUH-PIPELINE-READY` |
| Pipeline Windows + sinkhole | multi-sorgente senza egress | VALIDATED per checkpoint | `ENV-2026-06` |
| Pipeline appliance Audit/FIM | auditd + Whodata → Wazuh | VALIDATED per checkpoint | `ENV-2026-07` |

## Ambiente validato

- WAZUH-LAB: Ubuntu Server 24.04 LTS, `10.10.10.40/24`;
- Wazuh all-in-one 4.14.7;
- SINKHOLE-LAB: Debian 13, `10.10.10.30/24`;
- WIN11-LAB: Windows 11 Pro, `10.10.10.20/24`;
- APPLIANCE-LAB: Ubuntu Server 24.04 LTS, `10.10.10.50/24`;
- rete `lab-lan` senza forwarding e senza default route sui nodi operativi;
- NTP interno tramite host `10.10.10.1`;
- snapshot `WAZUH-TELEMETRY-READY`, `SINKHOLE-TELEMETRY-READY`, `WIN11-TELEMETRY-READY` e `APPLIANCE-TELEMETRY-READY`.

## Agent Linux: JSONL sinkhole

Il frammento `tio-sinkhole-jsonl.xml` configura `wazuh-logcollector` per seguire:

```text
/var/log/tio-sinkhole/requests.jsonl
```

Il formato è `json` e vengono aggiunte label di sorgente e ruolo. La validazione ha incluso backup di `ossec.conf`, test `wazuh-logcollector -t`, test `wazuh-agentd -t`, restart controllato e conferma degli alert.

## Agent Windows: EventChannel

Il frammento `tio-windows-eventchannels.xml` raccoglie gli eventi futuri dai canali:

- `Microsoft-Windows-Sysmon/Operational`;
- `Microsoft-Windows-PowerShell/Operational`;
- `Microsoft-Windows-TaskScheduler/Operational`.

I log `Application`, `Security` e `System` erano già acquisiti. L'auditing Task Scheduler `4698/4699` è stato abilitato separatamente tramite policy Windows.

## Agent Linux appliance: Audit e FIM

Il frammento `linux-fim/tio-appliance-fim.xml` documenta:

```xml
<directories check_all="yes" realtime="yes" whodata="yes" report_changes="yes">/opt/tio-appliance-lab/data</directories>
```

e la raccolta Audit:

```xml
<localfile>
  <log_format>audit</log_format>
  <location>/var/log/audit/audit.log</location>
</localfile>
```

Validazioni applicate:

```bash
/var/ossec/bin/wazuh-syscheckd -t
/var/ossec/bin/wazuh-agentd -t
/var/ossec/bin/wazuh-logcollector -t
systemctl restart wazuh-agent
```

Wazuh genera dinamicamente la watch:

```text
-w /opt/tio-appliance-lab/data -p wa -k wazuh_fim
```

Non deve essere aggiunta una seconda watch personalizzata sullo stesso percorso. Durante il primo test la sovrapposizione con `tio_appliance_files` impediva il corretto flusso Whodata; la watch duplicata è stata rimossa e il test è stato ripetuto con esito PASS.

## Mapping Audit sul manager

La lista CDB del manager è stata estesa con:

```text
tio_appliance_exec:execute
```

Dopo il restart del manager, l'esecuzione dello script sintetico ha generato:

| ID | Livello | Scopo |
|---:|---:|---|
| `80789` | 3 | execute watch su `tio-marker.sh` con chiave `tio_appliance_exec` |

## FIM rules validate

| ID | Evento | Scopo |
|---:|---|---|
| `554` | `added` | file creato nel percorso sintetico |
| `550` | `modified` | contenuto o attributi modificati |
| `553` | `deleted` | file cancellato |

I quattro record del ciclo positivo sono stati prodotti in modalità `whodata` con attribuzione a `labadmin` e al processo responsabile. Il test negativo sotto `/var/tmp` ha prodotto zero alert FIM TIO.

## SCA e plugin Audit Wazuh

Il plugin `/etc/audit/plugins.d/af_wazuh.conf` è stato portato a:

```text
mode=0640 owner=root group=root
```

Dopo il restart dell'agent il plugin, i servizi e la watch `wazuh_fim` sono rimasti operativi. I controlli SCA `35752` e `35754` hanno registrato la transizione `failed -> passed` tramite rule `19010`.

## Regole validate

### Sinkhole

| ID | Livello | Scopo |
|---:|---:|---|
| `100100` | 0 | regola padre per JSON di `requests.jsonl` |
| `100101` | 3 | heartbeat HTTP 200 |
| `100102` | 5 | risposta HTTP 404 |
| `100103` | 7 | metodo rifiutato con HTTP 405 |

### Windows

| ID | Livello | Scopo |
|---:|---:|---|
| `109910` | 5 | marker PowerShell Script Block Logging, Event ID 4104 |

La regola `109910` è stata validata in laboratorio; l'XML manager completo resta nello storage privato finché non termina la revisione dedicata del rule pack Windows.

## Query dashboard

```text
agent.id:"002" AND rule.id:"109910"
agent.id:"002" AND (rule.id:"67014" OR rule.id:"67015" OR rule.id:"60228")
agent.id:"001" AND data.path:"/final-natless-check"
agent.id:"003" AND data.audit.key:"tio_appliance_exec"
agent.id:"003" AND syscheck.path:"/opt/tio-appliance-lab/data/*"
```

## Validazione e rollback

Manager:

```bash
/var/ossec/bin/wazuh-analysisd -t
systemctl restart wazuh-manager
```

Agent Linux:

1. ripristinare il backup di `/var/ossec/etc/ossec.conf` o delle regole Audit;
2. validare i componenti interessati;
3. ricaricare `augenrules` quando necessario;
4. riavviare `wazuh-agent`;
5. verificare agent Active, watch `wazuh_fim` e alert.

## Limiti

- Le configurazioni pubblicate dimostrano la pipeline e non costituiscono un profilo di produzione.
- Marker, 404, 405 e singole modifiche FIM non dimostrano da soli attività malevola.
- Retention finale, matrice TP/TN, metriche e ripetizione completa dopo rollback restano da completare.
- `ENV-2026-07` non equivale a `LOGGING-READY`.

Evidenze collegate:

- [`../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`](../../evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md)
- [`../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md)
- [`../../evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md`](../../evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md)
