# Script

Gli script pubblici devono essere benigni, leggibili e limitati al laboratorio.

Struttura prevista:

```text
scripts/
├── common/
├── campaign-01-captivecrunch/
├── campaign-02-acr-stealer/
├── campaign-03-unc1069/
├── campaign-04-unc3753/
├── campaign-05-brickstorm/
└── campaign-06-winrar/
```

Ogni script deve avere:

- intestazione `LAB ONLY`;
- prerequisiti;
- input espliciti;
- destinazioni interne;
- nessun segreto;
- kill switch;
- cleanup corrispondente;
- output e codici di uscita documentati.
