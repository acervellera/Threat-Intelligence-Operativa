# Configurazioni

Qui vengono pubblicate solo configurazioni didattiche validate, ridotte e prive di segreti o identificatori locali.

## Configurazioni disponibili

| Area | File | Stato | Evidenza collegata |
|---|---|---|---|
| libvirt | [`libvirt/lab-lan.sanitized.xml`](libvirt/lab-lan.sanitized.xml) | VALIDATED | `ENV-2026-03` |
| sinkhole | [`sinkhole/server.py`](sinkhole/server.py) | VALIDATED | `ENV-2026-04` |
| sinkhole | [`sinkhole/tio-sinkhole.service`](sinkhole/tio-sinkhole.service) | VALIDATED | `ENV-2026-04` |
| sinkhole | [`sinkhole/tio-sinkhole.logrotate`](sinkhole/tio-sinkhole.logrotate) | VALIDATED | `ENV-2026-04` |
| sinkhole | [`sinkhole/README.md`](sinkhole/README.md) | PUBLIC | installazione, verifica e rollback |

La configurazione `lab-lan.sanitized.xml` documenta una rete host-only su `10.10.10.0/24`. Sono stati rimossi UUID, indirizzi MAC e altri metadati locali. L'assenza dell'elemento `<forward>` rappresenta il requisito di isolamento.

La directory `sinkhole/` documenta il servizio HTTP benigno validato su `10.10.10.30:8080`, con endpoint `/heartbeat`, logging JSONL, esecuzione non-root, hardening `systemd` e rotazione dei log.

## Struttura

```text
configs/
├── libvirt/
├── sinkhole/
├── sysmon/
├── wazuh/windows-eventchannel/
├── wazuh/rules/
├── auditd/
└── fim/
```

## Requisiti di pubblicazione

Ogni configurazione deve includere o essere accompagnata da:

- versione testata;
- data UTC;
- scopo e ambiente di validazione;
- limiti dichiarati;
- procedura di rollback;
- collegamento al test o all'evidenza che la valida;
- SHA-256 quando viene pubblicato un artefatto derivato stabile;
- rimozione di UUID, MAC, credenziali, token, percorsi host e identificatori reali.

## Regole specifiche per servizi

Le configurazioni applicative pubbliche devono inoltre dichiarare:

- indirizzo e porta di ascolto;
- utente e gruppo del processo;
- percorsi scrivibili;
- metodi o operazioni consentite;
- test positivi e negativi;
- politica di log e retention;
- procedura di arresto e rollback;
- dipendenze non ancora validate.

## Stato pianificato

| Directory | Scopo | Stato |
|---|---|---|
| `libvirt/` | rete e configurazioni VM sanificate | IN PROGRESS |
| `sinkhole/` | HTTP interno, systemd e logrotate | VALIDATED |
| `sysmon/` | configurazione Sysmon di laboratorio | NOT STARTED |
| `wazuh/windows-eventchannel/` | raccolta EventChannel Windows | NOT STARTED |
| `wazuh/rules/` | regole di detection custom | NOT STARTED |
| `auditd/` | audit Linux per execve, systemd e appliance | NOT STARTED |
| `fim/` | monitoraggio integrità file | NOT STARTED |

## Prossima configurazione

Il prossimo artefatto previsto è la configurazione di raccolta Wazuh per:

```text
/var/log/tio-sinkhole/requests.jsonl
```

La configurazione sarà pubblicata soltanto dopo verifica del parsing dei campi e del timestamp UTC.
