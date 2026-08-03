# 03 - UNC1069: fake meeting e browser extension

**Stato:** NOT STARTED

## Obiettivo sicuro

Social engineering tabletop -> inventario host -> estensione Chromium senza permessi -> staging crypto sintetico -> POST interno.

Non usare keylogging, accesso cookie, native host eseguibile, deepfake di persone reali o contatti reali.

## Passi

1. Preparare pagina meeting chiaramente LAB ed extension.
2. Eseguire tabletop del messaggio senza contattare persone.
3. Aprire il fake meeting con profilo disposable.
4. Eseguire ClickFix benigno e creare `host-inventory.json`.
5. Verificare che l'inventario contenga solo user, host, OS, time e tag LAB.
6. Analizzare manifest senza `permissions` e `host_permissions`.
7. Verificare `--load-extension` e path non gestito.
8. Copiare `wallet-inventory.csv` sintetico nello staging.
9. Verificare POST e SHA-256 del file pubblicabile.
10. Eseguire test negativo con extension approvata su host developer.

## Criteri di successo

- extension visibile senza dati browser reali;
- alert ClickFix/extension e POST correlabile;
- gap social-engineering/endpoint dichiarato;
- profilo, extension e staging rimossi senza toccare browser principale.
