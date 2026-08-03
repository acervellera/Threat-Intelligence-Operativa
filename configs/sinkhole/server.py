#!/usr/bin/env python3
"""
LAB ONLY — TIO internal HTTP sinkhole.

Scopo:
- esporre un endpoint benigno GET/HEAD /heartbeat;
- generare telemetria HTTP controllata nella rete isolata;
- registrare una riga JSON per ogni richiesta;
- rifiutare metodi che inviano o modificano dati.

Il programma non esegue comandi, non riceve file, non distribuisce payload e
non inoltra traffico verso destinazioni esterne.
"""

from __future__ import annotations

import json
import os
import threading
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlsplit


# Indirizzo statico della sola interfaccia di laboratorio.
# Non usare 0.0.0.0: esporrebbe il servizio su tutte le interfacce disponibili.
LISTEN_ADDRESS = "10.10.10.30"

# Porta TCP non privilegiata scelta per il servizio HTTP interno.
LISTEN_PORT = 8080

# Un evento JSON indipendente viene aggiunto per ogni richiesta.
LOG_PATH = "/var/log/tio-sinkhole/requests.jsonl"

# ThreadingHTTPServer può gestire più richieste contemporaneamente.
# Il lock evita scritture sovrapposte nel file JSONL.
LOG_LOCK = threading.Lock()


def utc_now() -> str:
    """Restituisce il timestamp corrente in UTC e formato ISO 8601."""

    return datetime.now(timezone.utc).isoformat()


class SinkholeHandler(BaseHTTPRequestHandler):
    """Gestore delle richieste HTTP del sinkhole."""

    # HTTP/1.0 chiude normalmente la connessione dopo ogni risposta.
    protocol_version = "HTTP/1.0"

    # Header Server ridotto: non pubblica la versione di Python.
    server_version = "TIO-Sinkhole/1.0"
    sys_version = ""

    def send_json(self, status: HTTPStatus, payload: dict[str, object]) -> None:
        """Invia una risposta HTTP JSON con header minimi di sicurezza."""

        # separators produce JSON compatto, utile per script e controlli automatici.
        body = json.dumps(payload, separators=(",", ":")).encode("utf-8")

        self.send_response(status.value)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))

        # Evita che browser o proxy conservino una risposta di health check.
        self.send_header("Cache-Control", "no-store")

        # Impedisce al browser di reinterpretare il JSON come HTML.
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()

        # HEAD restituisce gli stessi header di GET, ma non il corpo.
        if self.command != "HEAD":
            self.wfile.write(body)

    def write_event(self, status: int) -> None:
        """Registra la richiesta come singola riga JSON nel file JSONL."""

        parsed_url = urlsplit(self.path)

        # I campi controllati dal client sono limitati a 512 caratteri.
        event = {
            "timestamp_utc": utc_now(),
            "client_ip": self.client_address[0],
            "method": self.command,
            "path": parsed_url.path[:512],
            "query": parsed_url.query[:512],
            "user_agent": self.headers.get("User-Agent", "")[:512],
            "status": status,
        }

        log_line = json.dumps(event, separators=(",", ":")) + os.linesep

        # Una sola richiesta alla volta scrive nel file.
        with LOG_LOCK:
            # Modalità append: aggiunge la riga senza cancellare gli eventi precedenti.
            # Il blocco with chiude il file dopo ogni evento; per questo logrotate può
            # rinominare il file senza richiedere un riavvio del servizio.
            with open(LOG_PATH, "a", encoding="utf-8") as logfile:
                logfile.write(log_line)

    def handle_read_request(self) -> None:
        """Gestisce GET e HEAD; solo /heartbeat è un percorso valido."""

        requested_path = urlsplit(self.path).path

        if requested_path == "/heartbeat":
            status = HTTPStatus.OK
            payload = {
                "status": "ok",
                "service": "tio-sinkhole",
                "timestamp_utc": utc_now(),
            }
        else:
            status = HTTPStatus.NOT_FOUND
            payload = {
                "status": "error",
                "message": "not found",
            }

        self.send_json(status, payload)
        self.write_event(status.value)

    def do_GET(self) -> None:
        """Gestisce una richiesta GET."""

        self.handle_read_request()

    def do_HEAD(self) -> None:
        """Gestisce una richiesta HEAD senza corpo di risposta."""

        self.handle_read_request()

    def reject_method(self) -> None:
        """Rifiuta metodi che possono inviare o modificare contenuti."""

        status = HTTPStatus.METHOD_NOT_ALLOWED

        self.send_response(status.value)
        self.send_header("Allow", "GET, HEAD")
        self.send_header("Content-Length", "0")
        self.end_headers()

        self.write_event(status.value)

    def do_POST(self) -> None:
        """Rifiuta POST con HTTP 405."""

        self.reject_method()

    def do_PUT(self) -> None:
        """Rifiuta PUT con HTTP 405."""

        self.reject_method()

    def do_PATCH(self) -> None:
        """Rifiuta PATCH con HTTP 405."""

        self.reject_method()

    def do_DELETE(self) -> None:
        """Rifiuta DELETE con HTTP 405."""

        self.reject_method()

    def log_message(self, format_string: str, *args: object) -> None:
        """Disabilita il log testuale standard; viene usato soltanto JSONL."""

        return


def main() -> None:
    """Crea il socket HTTP e avvia il ciclo del server."""

    server = ThreadingHTTPServer(
        (LISTEN_ADDRESS, LISTEN_PORT),
        SinkholeHandler,
    )

    server.serve_forever()


if __name__ == "__main__":
    main()
