# Evidenze pubbliche

Questa cartella ospita esclusivamente copie `SANITIZED`.

## Convenzione

```text
evidence/public/<CASE-ID>/
├── manifest.csv
├── E-001-endpoint-events.csv
├── E-002-process-tree.csv
├── E-002-process-tree.png
├── E-003-artifacts.csv
├── E-004-network.jsonl
├── E-005-alert.json
└── E-006-cleanup.md
```

Le evidenze raw devono restare in `evidence/private`, `evidence/raw` o in uno storage esterno: queste directory sono escluse da Git.

## Manifest minimo

Per ogni file pubblico registrare Evidence ID, classificazione, timestamp UTC, SHA-256, fonte, trasformazioni applicate e reviewer.
