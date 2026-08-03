# 01 - Metodo: leggere una campagna come detection engineer

## Sei livelli

| Livello | Domanda | Output |
|---|---|---|
| Contesto | Chi è il target, il movente e quali precondizioni servono? | Victimology, asset, identity e business impact |
| Catena | Quali passaggi minimi collegano il lure all'obiettivo? | Sequenza di 5-12 eventi |
| ATT&CK | Quali tecniche sono osservate, derivate o ipotizzate? | Matrice A/B/C |
| Emulazione | Quale comportamento innocuo genera telemetria equivalente? | Azioni, input, output e limiti |
| Detection | Quali eventi e correlazioni discriminano il comportamento? | Event ID, campi, query, regole e tuning |
| Response | Cosa deve fare l'analista dopo l'alert? | Triage, scope, containment, eradication e report |

## Confidence A/B/C

- **A - Osservato:** la fonte descrive esplicitamente il comportamento o mostra artefatti.
- **B - Derivato:** la tecnica è conseguenza diretta del comportamento descritto.
- **C - Ipotesi:** tecnica plausibile ma non dimostrata; usarla come domanda di hunting.

Non trasformare capacità potenziali del malware in tecniche certamente usate. Separare sempre comportamento della campagna, capacità del tool e comportamento riprodotto nel lab.

## Scheda pre-lab

1. Scrivere la catena in linguaggio neutro.
2. Indicare i passaggi non visibili con Sysmon e la fonte alternativa.
3. Definire eventi e ordine del test positivo.
4. Definire attività legittima simile per il test negativo.
5. Definire kill switch e cleanup.
6. Assegnare Exercise ID, host, snapshot, operatore, start/stop UTC.

Usare [`templates/runbook.md`](../../templates/runbook.md).
