# 05 - Reporting professionale

## Pacchetto di un caso

- Campaign brief di una pagina.
- ATT&CK map con confidence A/B/C.
- Runbook con prerequisiti, limiti e cleanup.
- Evidence register E-001...E-006.
- Timeline UTC.
- Detection e matrice test.
- Finding da penetration test.
- Incident response report.

## Timeline

Ogni riga deve contenere UTC, fonte, evento, confidence, interpretazione ed Evidence ID. Separare fatti, inferenze e aspetti non determinabili.

## Finding

Il finding deve includere titolo, severità motivata, executive summary, scope, procedura ripetibile, evidenze, ATT&CK, impatto, root cause, remediation, retest e limitazioni.

## Incident response

Il report IR deve includere timeline, scope, initial access confirmed/probable/unknown, TTP osservate/inferite/non determinate, containment, eradication, recovery, impact, root cause, lessons learned e chain of custody.

I modelli sono nella cartella [`templates`](../../templates/).
