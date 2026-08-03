# 06 - Pubblicazione e anonimizzazione

## Flusso

1. Copiare l'artefatto raw nello staging privato.
2. Estrarre solo i campi necessari alla dimostrazione.
3. Sostituire identificatori reali con placeholder coerenti.
4. Rimuovere metadati, EXIF, nomi file e percorsi sensibili.
5. Verificare che screenshot e command line non contengano dati nascosti.
6. Calcolare SHA-256 della copia pubblica.
7. Aggiornare evidence register e manifest.
8. Eseguire review tecnica, privacy e sicurezza.
9. Pubblicare tramite pull request.

## Non pubblicare

- raw EVTX/PCAP/memory dump;
- log completi;
- host, utenti, tenant, e-mail, domini o IP reali;
- credenziali, cookie, token o documenti;
- malware, exploit, shellcode o archive exploit;
- dettagli non necessari a dimostrare la detection.

## Principio di minimizzazione

La copia pubblica deve essere sufficiente a verificare la conclusione, ma non a ricostruire l'ambiente privato.

Usare [`templates/publication-checklist.md`](../../templates/publication-checklist.md).
