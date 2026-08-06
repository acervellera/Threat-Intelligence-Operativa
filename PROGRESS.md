# Stato di avanzamento

Aggiornare questo file soltanto quando esiste un'evidenza verificabile. Un checkpoint parziale può portare una fase a `IN PROGRESS`, ma `VALIDATED` richiede il completamento della relativa Definition of Done.

## Riepilogo

| Indicatore | Valore |
|---|---|
| Fase primaria attiva | `STEP-02 — Rete e VM` |
| Attività parallele | `STEP-03 — Baseline telemetria`, `STEP-04 — Smoke test` |
| Ultimo checkpoint | `ENV-2026-07 — APPLIANCE-LAB telemetry ready` |
| Ultimo aggiornamento | `2026-08-06 UTC` |
| Prossima attività | retention, matrice TP/TN, metriche e rollback coordinato |
| Track A | quattro nodi `TELEMETRY-READY`; gate globale aperto |
| Track B | `PLANNED / BLOCKED`; dopo `LOGGING-READY` e primo caso benigno completo |
| Issue topologia | `#3 — Costruire rete host-only e macchine virtuali` |
| Issue smoke test | `#5 — Dataset sintetico, sinkhole e snapshot LOGGING-READY` |

## Avanzamento complessivo

| ID | Fase | Stato | Evidence / PR | Data UTC |
|---|---|---|---|---|
| STEP-00 | Governance e publication gate | IN PROGRESS | storage privato e `.gitignore` verificati | 2026-08-03 |
| STEP-01 | Metodo analitico A/B/C | NOT STARTED | - | - |
| STEP-02 | Rete e VM | IN PROGRESS | `ENV-2026-03`…`ENV-2026-07`; quattro nodi principali isolati | 2026-08-06 |
| STEP-03 | Wazuh, Sysmon, PowerShell e auditd | IN PROGRESS | Windows, sinkhole, auditd e FIM Whodata validati | 2026-08-06 |
| STEP-04 | Smoke test e snapshot LOGGING-READY | IN PROGRESS | quattro snapshot `*-TELEMETRY-READY`; non è `LOGGING-READY` | 2026-08-06 |
| CASE-01 | CaptiveCrunch / Storm-2945 — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-02A | ACR Stealer Chain A — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-02B | ACR Stealer Chain B — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-03 | UNC1069 — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-04 | UNC3753 / Luna Moth — Track A | BLOCKED | attende `LOGGING-READY` | - |
| CASE-05 | BRICKSTORM — Track A | BLOCKED | attende `LOGGING-READY-LINUX` | - |
| CASE-06 | WinRAR CVE-2025-8088 — Track A | BLOCKED | attende `LOGGING-READY` | - |
| TRACK-B | Malware analysis separata | PLANNED / BLOCKED | attende `LOGGING-READY` e primo caso Track A completo | 2026-08-06 |
| STEP-11 | Test matrix e metriche | NOT STARTED | - | - |
| STEP-12 | Portfolio finale | NOT STARTED | - | - |

## Ordine operativo approvato

1. completare la Track A fino a `LOGGING-READY` e `LOGGING-READY-LINUX`;
2. completare il primo caso benigno end-to-end nella Track A;
3. costruire una sola volta la Track B separata e sacrificabile;
4. ripetere il primo caso con analisi statica e dinamica solo se appropriata;
5. confrontare fonti, emulazione e comportamento osservato;
6. aggiornare detection, gap, tuning e report;
7. applicare il ciclo a due track ai casi successivi.

La Track B non usa `lab-lan`, non usa WAZUH-LAB e non viene eseguita contemporaneamente alla Track A sullo stesso host. La metodologia completa è descritta in `docs/07-malware-analysis-track/README.md`.

## Checkpoint pubblicati

| Exercise ID | Fase | Artefatto | Esito | Data UTC |
|---|---|---|---|---|
| `ENV-2026-03` | STEP-02 | SINKHOLE-LAB isolata con snapshot `CLEAN-OS` | PASS | 2026-08-03 |
| `ENV-2026-04` | STEP-04 parziale | HTTP, JSONL, logrotate, health check e `SINKHOLE-READY` | PASS | 2026-08-03 |
| `ENV-2026-05` | STEP-03/04 parziale | Wazuh all-in-one, JSONL e `WAZUH-PIPELINE-READY` | PASS | 2026-08-04 |
| `ENV-2026-06` | STEP-02/03/04 parziale | Windows telemetry, NTP, dataset e smoke test NAT-less | PASS parziale | 2026-08-05 |
| `ENV-2026-07` | STEP-02/03/04 parziale | auditd, FIM Whodata, test isolato e snapshot appliance | PASS parziale | 2026-08-06 |

## Dettaglio STEP-02

| Componente | Stato | Nota |
|---|---|---|
| KVM/QEMU e libvirt | VALIDATED | accelerazione hardware e gestione VM operative |
| Rete `lab-lan` | VALIDATED | `10.10.10.0/24`, nessun forwarding |
| NTP interno | VALIDATED | host `10.10.10.1`; client `.20`, `.30`, `.40`, `.50` verificati |
| WIN11-LAB | WIN11-TELEMETRY-READY | `10.10.10.20/24`, NAT rimossa, zero default route |
| SINKHOLE-LAB | SINKHOLE-TELEMETRY-READY | `10.10.10.30/24`, HTTP/JSONL e agent validati |
| WAZUH-LAB | WAZUH-TELEMETRY-READY | `10.10.10.40/24`, pipeline multi-sorgente validata |
| APPLIANCE-LAB | APPLIANCE-TELEMETRY-READY | `10.10.10.50/24`, auditd/FIM, NAT rimossa, zero default route |
| ANALYST-LAB | OPTIONAL | indirizzo previsto `10.10.10.60` |

## Dettaglio ENV-2026-07

### Baseline e isolamento

| Controllo | Stato |
|---|---|
| Ubuntu Server 24.04 LTS minimizzato | PASS |
| root LVM esteso a circa 38 GiB | PASS |
| snapshot `CLEAN-OS` a VM spenta | PASS |
| sola `lab-lan` su `10.10.10.50/24` | PASS |
| NIC NAT rimossa | PASS |
| default route assente | PASS |
| accesso Internet assente | PASS |
| NTP interno `10.10.10.1` sincronizzato | PASS |

### Auditd e Wazuh

| Controllo | Stato |
|---|---|
| `auditd` e `audispd-plugins` installati | PASS |
| marker audit locale e `lost=0` | PASS |
| Wazuh Agent 4.14.7 / ID `003` Active | PASS |
| `/var/log/audit/audit.log` raccolto | PASS |
| mapping `tio_appliance_exec:execute` | PASS |
| alert rule `80789` | PASS |

### FIM Whodata

| Controllo | Stato |
|---|---|
| percorso `/opt/tio-appliance-lab/data` | PASS |
| watch dinamica `wazuh_fim` | PASS |
| file added / rule `554` | PASS |
| contenuto modified / rule `550` | PASS |
| permessi modified / rule `550` | PASS |
| file deleted / rule `553` | PASS |
| attribuzione `labadmin` e processo | PASS |
| test negativo sotto `/var/tmp` | PASS |

La prima configurazione conteneva una watch Audit duplicata sul percorso FIM. La watch personalizzata è stata rimossa e il ciclo è stato ripetuto con la sola chiave dinamica `wazuh_fim`.

### SCA e snapshot

| Controllo | Stato |
|---|---|
| SCA `35752` modalità file Audit | `failed -> passed` |
| SCA `35754` gruppo file Audit | `failed -> passed` |
| configurazione stabile dopo restart agent | PASS |
| bundle pre e post isolamento verificati | PASS |
| snapshot `APPLIANCE-TELEMETRY-READY` | PASS |
| riavvio, SSH e agent Active dopo snapshot | PASS |

## Snapshot e integrità privata

| Nodo | Snapshot | Stato |
|---|---|---|
| WIN11-LAB | `WIN11-TELEMETRY-READY` | PASS |
| WAZUH-LAB | `WAZUH-TELEMETRY-READY` | PASS |
| SINKHOLE-LAB | `SINKHOLE-TELEMETRY-READY` | PASS |
| APPLIANCE-LAB | `APPLIANCE-TELEMETRY-READY` | PASS |

Pacchetti privati, manifesti SHA-256 e metadati XML sono stati verificati prima e dopo il trasferimento. Non sono pubblicati nel repository.

## Evidenze e configurazioni pubbliche

- `evidence/sanitized/ENV-2026-03-sinkhole-baseline.md`;
- `evidence/sanitized/ENV-2026-04-sinkhole-ready.md`;
- `evidence/sanitized/ENV-2026-05-wazuh-sinkhole-pipeline.md`;
- `evidence/sanitized/ENV-2026-06-multisource-telemetry-ready.md`;
- `evidence/sanitized/ENV-2026-07-appliance-telemetry-ready.md`;
- `configs/sinkhole/`;
- `configs/auditd/70-tio-appliance.rules`;
- `configs/wazuh/linux-localfile/tio-sinkhole-jsonl.xml`;
- `configs/wazuh/linux-fim/tio-appliance-fim.xml`;
- `configs/wazuh/lists/tio-audit-keys.txt`;
- `configs/wazuh/windows-eventchannel/tio-windows-eventchannels.xml`;
- `configs/wazuh/rules/tio_sinkhole_rules.xml`;
- `scripts/lab/tio-marker.sh`;
- `docs/07-malware-analysis-track/README.md`.

## Limiti correnti

- `ENV-2026-07` non equivale a `LOGGING-READY`.
- Retention finale, matrice TP/TN, metriche e ripetizione completa dopo rollback restano da completare.
- La Track B è soltanto pianificata e non deve essere avviata prima dei gate dichiarati.
- La regola Windows `109910` è validata nel laboratorio; la pubblicazione dell'XML manager completo richiede una revisione dedicata.
- Le raw evidence, gli inventari completi, gli UUID, i MAC, le credenziali, gli archivi privati, i percorsi locali, i campioni e il materiale contaminato restano fuori dal repository.

## Regole di aggiornamento

- `NOT STARTED`: nessuna attività verificabile iniziata.
- `NEXT`: prossimo componente pianificato.
- `PLANNED / BLOCKED`: attività definita ma non eseguibile finché i gate precedenti non sono soddisfatti.
- `IN PROGRESS`: lavoro avviato; possono esistere checkpoint ed evidenze parziali.
- `BLOCKED`: attività non eseguibile finché non viene superato un gate precedente.
- `VALIDATED`: Definition of Done della fase completata con test ripetibili.
- `SANITIZED`: artefatto pubblico revisionato per privacy e sicurezza.
- `PUBLISHED`: caso completo pubblicato con evidenze, hash, fonti e limiti.

Per i casi operativi, `VALIDATED` richiede almeno test positivo, test negativo, rollback o cleanup e verifica della baseline.
