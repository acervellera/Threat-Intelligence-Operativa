# 00 — Costruzione e validazione dell'ambiente

**Stato:** `IN PROGRESS`  
**Fase primaria:** `STEP-02 — Rete e VM`  
**Ultimo checkpoint:** `ENV-2026-09 — matrice formale TP/TN multi-nodo`  
**Retention:** `PASS`  
**Matrice TP/TN:** `14/14 PASS`  
**Prossimo checkpoint:** metriche, smoke test coordinato e rollback

## Obiettivo

Arrivare a una baseline ripetibile da cui iniziano tutti i casi, mantenendo separate installazione/patching, rete operativa isolata, raw evidence private ed evidenze pubbliche sanificate.

## Stato della topologia

| Nodo | IP | Stato | Snapshot |
|---|---|---|---|
| Host Ubuntu / `lab-lan` | `10.10.10.1` | bridge e NTP interno VALIDATED | n/a |
| WIN11-LAB | `10.10.10.20` | isolata, agent Active, telemetria Windows validata | `WIN11-TELEMETRY-READY` |
| SINKHOLE-LAB | `10.10.10.30` | isolata, HTTP/JSONL e agent validati | `SINKHOLE-TELEMETRY-READY` |
| WAZUH-LAB | `10.10.10.40` | isolata, pipeline multi-sorgente validata | `WAZUH-TELEMETRY-READY` |
| APPLIANCE-LAB | `10.10.10.50` | isolata, auditd/FIM Whodata e agent validati | `APPLIANCE-TELEMETRY-READY` |
| ANALYST-LAB | `10.10.10.60` | OPTIONAL | - |

## Checkpoint verificati

| Exercise ID | Ambito | Esito |
|---|---|---|
| `ENV-2026-03` | baseline isolata SINKHOLE-LAB | PASS |
| `ENV-2026-04` | sinkhole HTTP/JSONL e health check | PASS |
| `ENV-2026-05` | Wazuh ↔ sinkhole isolato | PASS |
| `ENV-2026-06` | Windows + sinkhole + Wazuh | PASS parziale |
| `ENV-2026-07` | APPLIANCE auditd/FIM Whodata | PASS parziale |
| `ENV-2026-08` | retention finale multi-nodo | PASS |
| `ENV-2026-09` | matrice formale 8 TP + 6 TN | PASS |

## Flusso validato

```text
WIN11-LAB -> EventChannel/Sysmon -> Agent 002 ┐
SINKHOLE-LAB -> JSONL -> Agent 001            ├-> WAZUH-LAB -> Indexer -> Dashboard
APPLIANCE-LAB -> auditd/FIM -> Agent 003      ┘
```

I quattro nodi principali usano esclusivamente `lab-lan` durante i checkpoint finali.

## Retention — ENV-2026-08

- WAZUH-LAB: rotazione alert verificata, `logall/logall_json` disabilitati;
- SINKHOLE-LAB: logrotate giornaliero, 14 rotazioni, maxsize 10 MiB e compressione;
- APPLIANCE-LAB: auditd con rotazione locale e policy low-space/full;
- WIN11-LAB: capacità Event Log aumentate e modalità circolare verificata.

Evidenza: [`ENV-2026-08-retention-baseline.md`](../../evidence/sanitized/ENV-2026-08-retention-baseline.md).

## Matrice formale — ENV-2026-09

Risultato: **14/14 PASS**.

| Area | TP | TN |
|---|---:|---:|
| Windows | 2 | 2 |
| Sinkhole | 3 | 2 |
| Audit Linux | 1 | 1 |
| FIM Linux | 2 | 1 |

La matrice ha inoltre documentato la contaminazione del test harness PowerShell, il comportamento discovery di Security 4699 e il cleanup FIM `553`.

Evidenza: [`ENV-2026-09-formal-tp-tn-matrix.md`](../../evidence/sanitized/ENV-2026-09-formal-tp-tn-matrix.md).

## Gate completati

- [x] hypervisor KVM/QEMU e libvirt;
- [x] rete host-only `10.10.10.0/24` senza forwarding;
- [x] quattro VM principali;
- [x] NTP interno;
- [x] NAT rimossa e zero default route;
- [x] sinkhole HTTP/JSONL;
- [x] Wazuh all-in-one e tre agent Active;
- [x] telemetria Windows;
- [x] auditd e FIM Whodata;
- [x] snapshot `*-TELEMETRY-READY`;
- [x] retention finale;
- [x] matrice TP/TN multi-nodo;
- [x] cleanup FIM osservato.

## Gate ancora aperti

- [ ] metriche formali;
- [ ] smoke test coordinato dei quattro nodi;
- [ ] ripetizione completa dopo rollback;
- [ ] verifica globale cleanup e baseline;
- [ ] inventario globale degli snapshot;
- [ ] snapshot `LOGGING-READY`;
- [ ] snapshot `LOGGING-READY-LINUX`.

## Definition of Done

La fase ambiente sarà `VALIDATED` quando tutti i nodi principali saranno isolati, gli agent online, i campi chiave visibili, retention e test matrix formalizzati, il test ripetibile dopo rollback, il cleanup globale verificato e gli snapshot finali coordinati creati.

`ENV-2026-09` chiude retention e matrice TP/TN, ma non chiude ancora la fase ambiente.
