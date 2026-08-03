# Contribuire

## Flusso

1. Creare una issue per lo step o il caso.
2. Lavorare su branch `step/<id>-descrizione` o `case/<id>-descrizione`.
3. Aggiornare il runbook e le evidenze sanificate.
4. Aprire una pull request.
5. Completare la publication checklist.
6. Eseguire review tecnica, privacy e cleanup.

## Requisiti di un caso

Una campagna è accettabile solo se contiene:

- fonti e data di consultazione;
- separazione osservato/derivato/ipotesi;
- prerequisiti e snapshot;
- procedura numerata;
- telemetria attesa e gap;
- test positivo e almeno un test negativo;
- evidenze E-001...E-006;
- hash delle copie pubbliche;
- cleanup verificato;
- finding e incident response;
- limiti espliciti di ciò che non è stato riprodotto.

## Commit

Usare messaggi brevi e descrittivi:

- `docs: add CaptiveCrunch case brief`
- `lab: validate Sysmon telemetry smoke test`
- `detection: add Wazuh negative test`
- `evidence: publish sanitized CASE-01 timeline`
- `chore: verify cleanup baseline`

## Pull request

Non approvare una PR se contiene file raw, identificatori reali, segreti, payload operativi o affermazioni ATT&CK senza confidence e fonte.
