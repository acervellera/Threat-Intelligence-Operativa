# 04 - UNC3753 / Luna Moth

**Stato:** NOT STARTED

## Obiettivo sicuro

Servizio remote-support benigno -> discovery -> staging di documenti legali sintetici -> archivio -> upload al sinkhole.

Nessuna connessione remota reale, credenziale, Dropbox o cloud pubblico.

## Prerequisiti

- PowerShell amministrativa per servizio LAB;
- `C:\Lab\Synthetic\Legal` con documenti fittizi;
- sinkhole con POST;
- monitoraggio System 7045.

## Passi

1. Condurre tabletop vishing e fermarsi prima di password, MFA o tool reali.
2. Creare record servizio `LabRemoteSupport` senza avviarlo.
3. Avviare heartbeat separato e comandi discovery benigni.
4. Analizzare 7045, `sc.exe`, ImagePath, account e start type.
5. Analizzare `whoami` e `ipconfig` nella sequenza.
6. Copiare 20 file sintetici, creare ZIP e calcolarne hash.
7. Correlare archive -> utility transfer -> POST interno.
8. Eseguire test negativo con service/backup approvato.
9. Documentare decisione IR e criteri di isolamento.

## Criteri di successo

- alert per servizio non approvato e upload nella stessa finestra;
- evidenza del controllo umano che interrompe il vishing;
- timeline con file count e byte;
- distinzione tra ransomware e data theft extortion;
- cleanup completo.
