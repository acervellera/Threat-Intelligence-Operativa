# 00 - Governance, classificazione e sicurezza

## Classificazione

| Livello | Uso | Repository pubblico |
|---|---|---|
| PUBLIC | Documentazione generale e fonti pubbliche | Sì |
| SANITIZED | Copia ridotta e anonimizzata di un artefatto LAB | Sì, dopo review |
| PRIVATE | Raw log, acquisizioni, screenshot non revisionati, note interne | No |

## Tassonomia evidenze

| ID | Artefatto | Formato pubblico consigliato | Campi minimi |
|---|---|---|---|
| E-001 | Eventi endpoint | CSV/JSON ridotto | log, Event ID, record ID, host placeholder, user placeholder, UTC |
| E-002 | Process tree | PNG revisionato + CSV | parent, child, command line sanificata, PID, hash |
| E-003 | File/registry/task/service | CSV/JSON + hash | path sanificato, owner, timestamp, SHA-256 |
| E-004 | Rete | JSONL/CSV ridotto | source, destination LAB, metodo, byte, URI sanificata |
| E-005 | Detection | Alert JSON ridotto | Rule ID, level, MITRE, campi matched |
| E-006 | Cleanup | Checklist | artefatti rimossi e verifica baseline |

## Placeholder standard

- `<HOST-WIN-01>`
- `<HOST-LINUX-01>`
- `<USER-LAB>`
- `<INTERNAL-IP>`
- `<LAB-DOMAIN>`
- `<CASE-ID>`
- `<UTC-TIMESTAMP>`

Usare lo stesso placeholder in tutti gli artefatti del caso per preservare la correlazione senza esporre dati.

## Gate obbligatorio

Prima del lab: autorizzazione, snapshot, test positivo, test negativo, kill switch e cleanup.

Prima della pubblicazione: riduzione dei dati, anonimizzazione, revisione metadati, hash, manifest e pull request.
