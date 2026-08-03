# 01 - CaptiveCrunch / Storm-2945

**Stato:** NOT STARTED  
**Exercise ID suggerito:** `EX-CAPTIVE-001`

## Obiettivo sicuro

Riprodurre ClickFix -> PowerShell benigno -> Run key + task -> browser remote debugging su profilo sintetico -> heartbeat interno.

Non riprodurre device code reale, cookie theft, UAC bypass o AMSI tampering.

## Prerequisiti

- snapshot `LOGGING-READY`;
- sinkhole raggiungibile;
- dataset browser sintetico;
- browser senza account e sincronizzazione;
- egress Internet bloccato.

## Passi

1. Avviare sinkhole e registrare UTC.
2. Preparare pagina captive portal LAB.
3. Riprodurre gesto ClickFix con script benigno.
4. Verificare marker e HTTP.
5. Verificare Run key `LabCloudSync`.
6. Verificare scheduled task `Lab Cloud Sync Update`.
7. Analizzare `-EncodedCommand` in Sysmon 1 e 4104.
8. Validare browser con profilo sintetico e remote debugging.
9. Ingerire evento device-code statico senza autenticazione reale.
10. Costruire timeline browser -> PowerShell -> file -> Run key -> task -> browser debug -> HTTP.

## Telemetria

Sysmon 1/3/13/22, PowerShell 4104, Security 4698, TaskScheduler, sinkhole JSONL.

## Criteri di successo

- alert per ClickFix, Run key, task e browser debug;
- timeline completa entro cinque minuti;
- test negativo amministrativo non genera alert critico correlato;
- report dichiara ciò che non è stato riprodotto.
