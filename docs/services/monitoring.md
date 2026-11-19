# Monitoring

Full observability audit, 2026-11-19 (live-checked: Prometheus target API,
Grafana API, container inventory on both hosts).

## Architecture (as-is)

**Central plane — gatekeeper** (compose:
[docker-compose.monitoring.yml](../machines/gatekeeper/docker-compose.monitoring.yml),
live configs in `/srv/infra/configs/`, repo mirror:
[configs/monitoring/](../machines/gatekeeper/configs/monitoring/)):

| Component | Bind | Notes |
|-----------|------|-------|
| Prometheus (30 d retention) | `127.0.0.1:9090` | 15 s scrape; `--web.enable-lifecycle` on |
| Grafana | `127.0.0.1:3000` | public via grafana.perdrizet.org; SMTP notifications |
| Alertmanager | `127.0.0.1:9093` | email routing (critical 4 h repeat / warning 12 h); real config host-only, [example in repo](../machines/gatekeeper/configs/monitoring/alertmanager.example.yml) |
| Loki + Promtail | `127.0.0.1:3100` | tails `/var/log` + docker container logs **on gatekeeper only** |
| exporters | internal | node, cadvisor, nginx, blackbox — **all gatekeeper-local** |

**Silo — pyrite** ([postgreSQL-server teaching demo](https://github.com/gperdrizet/postgreSQL-server)):
its own `prometheus` (`100.64.0.2:9090`) + `grafana` (`100.64.0.2:3000`) +
postgres-exporter, scraping only itself + postgres. Deliberately separate;
leave it alone, but it monitors **nothing homelab-relevant**.

## What Prometheus actually scrapes (live target API, 2026-11-19)

**Up:**

| Job | Target | Covers |
|-----|--------|--------|
| prometheus | gatekeeper | self |
| node-exporter | gatekeeper | host CPU/RAM/disk |
| cadvisor | gatekeeper | containers |
| nginx | gatekeeper | request rates |
| headscale | gatekeeper:9099 | tailnet control |
| logkeep-production | logkeep:8000 | app metrics |
| logkeep-postgres-exporter / bench-postgres-exporter | gatekeeper | app DBs |
| pyrite-postgres-exporter | `100.64.0.2:9187` | pyrite PostgreSQL ✓ |
| ssl-certs / ssl-certs-reachable | blackbox ×7 | 7 public HTTPS endpoints |

**Down (dead config — remove):**

| Job | Target | Why dead |
|-----|--------|----------|
| llamacpp-pyrite | `100.64.0.2:8502/metrics` | port 8502 is now LiteLLM; no `/metrics` |
| llamacpp-pyrite-batch ×2 | `:8503`, `:8504` | old batch llama.cpp systemd units deleted |

## What is NOT monitored (holes)

| Gap | Detail |
|-----|--------|
| **LLM inference stack** | Nothing in the promptly chain emits or scrapes metrics: model-gateway-api has no `/metrics` (404); LiteLLM runs with Prometheus metrics **disabled** (`/metrics` 404; needs `metrics: true` in `/opt/litellm/config.json`); both llama-cuda containers run **without `--metrics`** (llama.cpp flag). The Grafana "Promptly: gateway traffic" dashboard has 4 llama.cpp panels that have shown no data since the container migration — its SQL panels (PostgreSQL model-gateway usage DB) are the only live ones. |
| **pyrite hardware** | No node_exporter → no CPU/RAM/disk-temperature visibility on the most load-bearing machine (root disk chronically ~93 % and nobody gets paged). |
| **pyrite GPUs** | No GPU exporter for the 2× P100s (dcgm-exporter or `nvml` exporter). |
| **pyrite containers** | No cadvisor on pyrite; central alert rules that use `container_*` only ever see gatekeeper. |
| **ethics-gradient** | Nothing at all: no node_exporter, no cadvisor, its llama-cuda has no metrics. |
| **NFS / the 15 TB array** | No `nfsd`/`nfs` node_exporter collectors enabled, no RAID/`md` or SMART collectors verified. |
| **Minecraft (the-educator)** | Unmonitored; not enrolled in tailnet. |
| **Logs beyond gatekeeper** | Loki collects only gatekeeper local/container logs; nothing ships from pyrite. |
| **Backups** | No metric or blackbox-style check for backup freshness; alert rule exists only as a commented-out stub. |

## Alerts (alert-rules.yml)

Live: app-down (logkeep), CPU/RAM/disk thresholds, pg down/connections,
container health (**gatekeeper names only**: logkeep/bench/headplane), SSL
expiry. **Nothing** fires for promptly inference, pyrite hardware, or ethics.

## Dashboards (live Grafana, 2026-11-19)

| Dashboard | Source of truth | Notes |
|-----------|----------------|-------|
| Homelab Monitoring Overview | repo-provisioned | |
| Gatekeeper Traffic Overview | repo-provisioned | |
| LogKeep Production Monitoring | repo-provisioned | |
| LogKeep Traffic Monitoring | repo-provisioned | |
| Promptly: gateway traffic | **UI-only** → now exported to repo mirror | 5 SQL panels (live) + 4 llama.cpp panels (dead until inference metrics exist) |

Datasources: Prometheus, Loki, PostgreSQL (→ logkeep db; the Promptly dashboard
uses a second PG datasource pointing at the model-gateway usage db).

## Config drift found

- Gatekeeper live `prometheus.yml` ≠ repo mirror (mirror lacked the dead
  llamacpp jobs) → mirror re-synced from live 2026-11-19.
- `alertmanager.yml` existed only on the host → redacted example now in repo.
  It contains a plaintext SMTP password (host file only — rotate + move to env
  file, tracked outside git).
- "Promptly: gateway traffic" existed only in Grafana → exported to
  [grafana-dashboards/](../machines/gatekeeper/configs/monitoring/grafana-dashboards/).

## Target state (proposal — pending owner go-ahead)

Centralize on the gatekeeper plane; pyrite keeps only the teaching stack.

1. **Emit**
   - Add `--metrics` to both llama-cuda containers (⚠ brief container restart).
   - Enable Prometheus metrics in LiteLLM config (`metrics: true`).
   - model-gateway: no metrics endpoint today; LiteLLM + llama.cpp coverage is
     probably sufficient — skip unless we want per-key counters from the gateway.
2. **Expose from pyrite** — new tailnet-bound exporter set (compose group):
   node_exporter (`:9101`? keep :9100 free — pick 910x plan), cadvisor,
   dcgm-exporter (P100), enable node `mdadm`+`smartctl` collectors for the
   RAID, optional `nfs` collector + nginx… (pyrite has no nginx; skip).
3. **Expose from ethics-gradient** — node_exporter + cadvisor.
4. **Scrape** — replace the 3 dead `llamacpp-*` jobs with:
   `litellm` (100.64.0.2:8502/metrics), `llamacpp-pyrite` (in-network exec or
   bind a metrics port), `llamacpp-ethics` (100.64.0.5:8080/metrics),
   `pyrite-node`, `pyrite-cadvisor`, `pyrite-gpu`, `ethics-node`,
   `ethics-cadvisor`.
5. **Alert** — inference-alive (`up{job=~"litellm|llamacpp.*"}`), pyrite root
   disk (the 93 % problem), pyrite RAID/SMART, GPU temp/util, ethics host,
   backup-freshness push metric.
6. **Dashboard** — extend homelab-overview (or new "Inference" dashboard) with
   LiteLLM + llama.cpp + hardware panels; fix the dead panels in the Promptly
   dashboard.
7. **Hygiene** — delete dead scrape jobs, keep repo mirror authoritative
   (edit in repo → copy to `/srv/infra` → `curl -X POST :9090/-/reload`).
