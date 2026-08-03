# ENV-2026-04 — SINKHOLE-READY

**Classificazione:** SANITIZED  
**Data UTC:** 2026-08-03  
**Stato:** PASS  
**Ambito:** checkpoint parziale di `STEP-04`; componente sinkhole completata, smoke test end-to-end ancora bloccato da Wazuh e dalle VM rimanenti

## Obiettivo

Validare un servizio HTTP interno, benigno e ripetibile sulla VM `SINKHOLE-LAB`, mantenendo la VM priva di accesso Internet e limitando il servizio alla rete di laboratorio `10.10.10.0/24`.

Il checkpoint verifica:

- endpoint di health check;
- risposte negative prevedibili;
- logging strutturato JSONL;
- esecuzione non privilegiata;
- rotazione e retention dei log;
- isolamento di rete;
- ripristinabilità tramite snapshot.

## Architettura validata

| Componente | Valore pubblico |
|---|---|
| VM | `SINKHOLE-LAB` |
| Sistema guest | Debian 13 amd64 |
| Indirizzo LAB | `10.10.10.30/24` |
| Rete | `lab-lan`, host-only |
| Default route | assente |
| Servizio | `tio-sinkhole.service` |
| Runtime | Python 3 |
| Utente di servizio | `tio-sinkhole` |
| Listener | `10.10.10.30:8080/TCP` |
| Endpoint valido | `GET /heartbeat` |
| Log corrente | `/var/log/tio-sinkhole/requests.jsonl` |
| Formato | JSON Lines, un evento per riga |
| Snapshot | `SINKHOLE-READY`, figlio di `CLEAN-OS` |

## Matrice dei test HTTP

| Test | Risultato atteso | Risultato osservato |
|---|---:|---:|
| `GET /heartbeat` | HTTP 200 e JSON valido | PASS |
| `HEAD /heartbeat` | HTTP 200 senza corpo | PASS |
| `GET /percorso-inesistente` | HTTP 404 e JSON di errore | PASS |
| `POST /heartbeat` | HTTP 405 | PASS |
| Richiesta dall'host LAB | client `10.10.10.1` nei log | PASS |
| Listener globale `0.0.0.0:8080` | assente | PASS |

La risposta positiva contiene i campi:

```json
{
  "status": "ok",
  "service": "tio-sinkhole",
  "timestamp_utc": "<ISO-8601 UTC>"
}
```

## Health check automatico

Lo script di verifica ha eseguito 16 controlli con risultato:

```text
Controlli superati: 16
Controlli falliti: 0
RISULTATO: PASS
```

Controlli inclusi:

1. servizio `systemd` attivo;
2. servizio abilitato all'avvio;
3. listener su `10.10.10.30:8080`;
4. assenza di listener globale su `0.0.0.0:8080`;
5. `GET /heartbeat` con HTTP 200;
6. JSON positivo conforme;
7. percorso inesistente con HTTP 404;
8. JSON 404 conforme;
9. `POST /heartbeat` rifiutato con HTTP 405;
10. processo eseguito come utente `tio-sinkhole`;
11. log corrente JSONL valido;
12. evento POST/405 presente nel log;
13. assenza di default route;
14. route `10.10.10.0/24` presente sull'interfaccia LAB;
15. timer `logrotate` attivo;
16. timer `logrotate` abilitato.

## Schema del log JSONL

Ogni richiesta produce un oggetto indipendente con campi stabili:

```json
{
  "timestamp_utc": "<ISO-8601 UTC>",
  "client_ip": "10.10.10.1",
  "method": "GET",
  "path": "/heartbeat",
  "query": "",
  "user_agent": "<client>",
  "status": 200
}
```

Gli eventi possono essere correlati tramite timestamp, client, metodo, percorso, User-Agent e codice HTTP. Non è ancora presente un identificatore di sessione o di esercizio nel singolo evento.

## Rotazione dei log

La configurazione `logrotate` è stata validata e forzata una volta in ambiente LAB.

| Parametro | Valore |
|---|---|
| Frequenza | giornaliera |
| Retention | 14 archivi |
| Rotazione anticipata | 10 MiB |
| Compressione | attiva |
| Primo archivio | non compresso fino alla rotazione successiva |
| File nuovo | `0640`, proprietario e gruppo `tio-sinkhole` |

Dopo la rotazione sono stati osservati:

```text
requests.jsonl      nuovo log attivo
requests.jsonl.1    log precedente archiviato
```

Una nuova richiesta è stata scritta correttamente nel file corrente senza riavviare il servizio. Questo comportamento è possibile perché il programma apre e chiude il file di log per ogni evento.

## Isolamento verificato

| Controllo | Esito |
|---|---|
| Comunicazione con host LAB `10.10.10.1` | PASS |
| Default route nella VM | assente |
| Raggiungibilità Internet | bloccata |
| Listener HTTP limitato all'IP LAB | PASS |
| Scheda NAT nella configurazione corrente | assente |

## Snapshot

Lo snapshot interno `SINKHOLE-READY` è stato creato a VM spenta il `2026-08-03T15:31:58Z`.

Relazione osservata:

```text
CLEAN-OS
└── SINKHOLE-READY  (current, internal, shutoff)
```

Lo snapshot non è un backup indipendente: rimane contenuto nel disco QCOW2 della VM.

## Evidenze private e limite della prima acquisizione aggregata

Le evidenze raw restano nello storage privato. Un'acquisizione aggregata privata è stata calcolata con SHA-256:

```text
c40da52460fc851c31b9af7a4ffa86346102fdea09d78c189dae04f8d9907c88
```

Quella prima acquisizione contiene i test HTTP dall'host, lo stato del servizio e l'isolamento di rete, ma due sezioni privilegiate eseguite tramite SSH non interattivo non sono state catturate perché `sudo` richiedeva un terminale. Il health check completo `16/16 PASS` e gli eventi JSONL sono stati verificati interattivamente prima dello spegnimento e della creazione dello snapshot.

Questa limitazione viene dichiarata per non rappresentare l'acquisizione aggregata come prova completa di ogni controllo.

## Configurazioni pubblicate

- [`../../configs/sinkhole/server.py`](../../configs/sinkhole/server.py)
- [`../../configs/sinkhole/tio-sinkhole.service`](../../configs/sinkhole/tio-sinkhole.service)
- [`../../configs/sinkhole/tio-sinkhole.logrotate`](../../configs/sinkhole/tio-sinkhole.logrotate)
- [`../../scripts/common/tio-sinkhole-check.sh`](../../scripts/common/tio-sinkhole-check.sh)

## Sanificazione applicata

Sono stati esclusi:

- UUID della VM;
- indirizzi MAC;
- percorsi dell'host personale;
- nomi utente dell'host;
- output SSH completi;
- immagini disco e snapshot;
- log raw completi;
- metadati locali non necessari alla ripetibilità.

## Limiti e attività residue

Questo checkpoint valida il solo servizio sinkhole. Non dimostra ancora:

- ingestione dei log in Wazuh;
- correlazione con telemetria Windows o Linux;
- test da `WIN11-LAB`;
- smoke test end-to-end;
- snapshot `LOGGING-READY` o `LOGGING-READY-LINUX`;
- ripetibilità dopo rollback dello snapshot `SINKHOLE-READY`.

La fase complessiva resta quindi `IN PROGRESS`.
