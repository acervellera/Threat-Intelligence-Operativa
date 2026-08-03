# 02 - ACR Stealer

**Stato:** NOT STARTED

## Obiettivo sicuro

### Chain A

Retrieval interno -> Python benigno -> scheduled task -> resolver JSON -> copia di browser store sintetici.

### Chain B

HTA benigno -> decoding di marker -> heartbeat.

Non usare DLL remote, shellcode, process hollowing o profili browser reali.

## Prerequisiti

- Python 3 su WIN11-LAB;
- file benigni nel sinkhole;
- dataset browser sintetico;
- regole Wazuh di base attive.

## Passi Chain A

1. Preparare file benigni.
2. Scaricare stage Python dal sinkhole.
3. Verificare Invoke-WebRequest, FileCreate e HTTP GET.
4. Verificare `python.exe` e marker.
5. Creare/esportare task `Lab ACR AutoUpdate`.
6. Verificare GET `resolver.json` e heartbeat.
7. Verificare staging di soli file sintetici.

## Passi Chain B

1. Avviare HTA locale benigno.
2. Decodificare un marker senza esecuzione in memoria.
3. Cercare `mshta.exe`, parent, path e marker.
4. Eseguire test negativo su HTA amministrativo/allowlisted.

## Criteri di successo

- Chain A produce almeno quattro eventi correlati;
- Chain B produce alert MSHTA e marker;
- gap delle letture browser documentato;
- le due catene restano separate nel report;
- cleanup verificato.
