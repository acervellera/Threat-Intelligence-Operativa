# Configurazioni

Qui vengono pubblicate solo configurazioni didattiche validate, ridotte e prive di segreti o identificatori locali.

## Configurazioni disponibili

| Area | File | Stato | Evidenza collegata |
|---|---|---|---|
| libvirt | [`libvirt/lab-lan.sanitized.xml`](libvirt/lab-lan.sanitized.xml) | VALIDATED | `ENV-2026-03` |

La configurazione `lab-lan.sanitized.xml` documenta una rete host-only su `10.10.10.0/24`. Sono stati rimossi UUID, indirizzi MAC e altri metadati locali. L'assenza dell'elemento `<forward>` rappresenta il requisito di isolamento.

## Struttura

```text
configs/
├── libvirt/
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

## Stato pianificato

| Directory | Scopo | Stato |
|---|---|---|
| `libvirt/` | rete e configurazioni VM sanificate | IN PROGRESS |
| `sysmon/` | configurazione Sysmon di laboratorio | NOT STARTED |
| `wazuh/windows-eventchannel/` | raccolta EventChannel Windows | NOT STARTED |
| `wazuh/rules/` | regole di detection custom | NOT STARTED |
| `auditd/` | audit Linux per execve, systemd e appliance | NOT STARTED |
| `fim/` | monitoraggio integrità file | NOT STARTED |
