# ENV-2026-03 — Baseline isolata SINKHOLE-LAB

**Classificazione:** SANITIZED  
**Data UTC:** 2026-08-03  
**Stato:** PASS  
**Ambito:** checkpoint parziale di `STEP-02`

## Obiettivo

Costruire e validare una VM Linux destinata al sinkhole interno, mantenendo separati il traffico di laboratorio e l'accesso Internet usato temporaneamente per installazione e patching.

## Configurazione validata

| Componente | Valore pubblico |
|---|---|
| Hypervisor | KVM/QEMU con libvirt |
| VM | `SINKHOLE-LAB` |
| Sistema guest | Debian 13 amd64 |
| Risorse | 2 vCPU, 2 GiB RAM, disco QCOW2 |
| Hostname | `sinkhole-lab` |
| Dominio LAB | `lab.internal` |
| Rete finale | `lab-lan`, host-only |
| Subnet | `10.10.10.0/24` |
| IP statico | `10.10.10.30/24` |
| Host libvirt | `10.10.10.1` |
| Snapshot | `CLEAN-OS` |

## Controlli eseguiti

| Controllo | Risultato |
|---|---|
| KVM e libvirt operativi | PASS |
| Rete `lab-lan` persistente e senza forwarding | PASS |
| IP statico presente sulla NIC LAB | PASS |
| Comunicazione VM → host `10.10.10.1` | PASS |
| Comunicazione host → VM `10.10.10.30` | PASS |
| SSH sulla rete LAB | PASS |
| NAT rimosso dopo aggiornamenti | PASS |
| Default route assente nella configurazione finale | PASS |
| Accesso Internet non raggiungibile | PASS |
| `ssh` attivo | PASS |
| `qemu-guest-agent` attivo | PASS |
| `spice-vdagent` attivo | PASS |
| Python 3, `curl` e `jq` installati | PASS |
| Directory applicative con permessi ridotti | PASS |
| Snapshot a VM spenta | PASS |

## Stato di rete finale

```text
SINKHOLE-LAB  10.10.10.30/24
      |
      | lab-lan / host-only
      |
Ubuntu host   10.10.10.1/24
```

La VM conserva una sola interfaccia collegata a `lab-lan`. Non è presente una route predefinita e la rete non contiene una modalità di forwarding NAT o routed.

## Servizi e directory predisposti

```text
SSH:                    active
QEMU guest agent:       active
SPICE guest agent:      active
/opt/tio-sinkhole:      labadmin:labadmin 0750
/var/log/tio-sinkhole:  labadmin:labadmin 0750
```

Il servizio HTTP sinkhole non è ancora stato implementato in questo checkpoint.

## Evidenze escluse dalla pubblicazione

Restano nello storage privato:

- output completi dei comandi;
- UUID e indirizzi MAC;
- percorsi locali dell'host;
- ISO e disco QCOW2;
- XML libvirt originale;
- metadati completi dello snapshot;
- credenziali e fingerprint SSH.

## Limiti

Questo checkpoint valida esclusivamente la baseline di `SINKHOLE-LAB`. `WIN11-LAB`, `WAZUH-LAB`, `APPLIANCE-LAB`, telemetria, heartbeat e smoke test non sono ancora completati. Di conseguenza `STEP-02` rimane `IN PROGRESS`.
