# 05 - BRICKSTORM su appliance Linux/vSphere

**Stato:** NOT STARTED

## Obiettivo sicuro

Installare un servizio systemd benigno che esegue solo DNS/HTTP heartbeat interno, validare FIM/auditd, creare un JSP marker e centralizzare i log.

Non usare exploit, shell, proxy, WebSocket C2, SOCKS o accesso vCenter reale.

## Prerequisiti

- APPLIANCE-LAB con Wazuh agent e auditd;
- egress deny, consentiti solo sinkhole e Wazuh;
- snapshot `LOGGING-READY-LINUX`;
- DNS LAB o fallimento DNS registrato.

## Passi

1. Applicare FIM e auditd.
2. Installare `lab-vami-http.service` benigno.
3. Verificare status, ExecStart, hardening e PID.
4. Verificare heartbeat in log locale e sinkhole.
5. Verificare FIM sul JSP marker privo di codice.
6. Mutare file/script e riavviare il servizio.
7. Correlare auditd execve e modifica file.
8. Analizzare periodicità del traffico.
9. Eseguire test negativo durante change window approvata.
10. Simulare retention gap e documentare che l'initial access non è ricostruibile.

## Criteri di successo

- alert su unit, JSP marker e mutazione;
- auditd collega actor e processo;
- heartbeat visibile in almeno due fonti;
- limiti dell'emulazione dichiarati;
- cleanup e rollback verificati.
