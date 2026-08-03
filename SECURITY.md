# Security Policy

## Perimetro autorizzato

Il progetto è esclusivamente difensivo e didattico. Le prove devono usare VM isolate, dati sintetici, snapshot e destinazioni interne.

## Attività vietate

- eseguire malware, stealer, backdoor o exploit operativi;
- usare credenziali, cookie, token, wallet o account reali;
- contattare domini pubblici come C2 o destinazioni di esfiltrazione;
- testare reti, dispositivi o persone senza autorizzazione;
- pubblicare evidenze raw o dati riconducibili a terzi;
- creare archivi weaponized o installare versioni vulnerabili per riprodurre CVE;
- implementare shell, SOCKS proxy, tunneling o controllo remoto arbitrario.

## Segnalazione di dati sensibili

Non aprire una issue pubblica contenente segreti o dati personali. Rimuovere immediatamente il dato dalla working copy e usare un canale privato verso il maintainer o una private security advisory, se disponibile.

## Risposta a una pubblicazione accidentale

1. Bloccare ulteriori push.
2. Rimuovere il contenuto dalla cronologia, non solo dall'ultimo commit.
3. Revocare o ruotare ogni segreto esposto.
4. Documentare l'incidente senza ripubblicare il dato.
5. Rieseguire la publication checklist.
