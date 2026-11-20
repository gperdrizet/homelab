# Monitoring

Full observability audit, 2026-11-19 (live-checked: Prometheus target API,
container inventory on both hosts). Updated 2026-11-19 evening after the
centralization pass.

## Architecture

**Single plane — gatekeeper** (compose:
[docker-compose.monitoring.yml](../machines/gatekeeper/docker-compose.monitoring.yml),
live configs in `/srv/infra/configs/`, repo mirror:
[configs/monitoring/](../machines/gatekeeper/configs/monitoring/) — the mirror
is authoritative; edit repo → scp → `curl -X POST :9090/-/reload`).

| Component | Bind | Notes |
|-----------|------|-------|
| Prometheus (30 d retention) | `127.0.0.1:9090` | 15 s scrape; `--web.enable-lifecycle` on |
| Grafana | `127.0.0.1:3000` | public via grafana.perdrizet.org; SMTP notifications; dashboards file-provisioned from `/srv/infra/configs/grafana-dashboards/` |
| Alertmanager | `127.0.0.1:9093` | email routing (critical 4 h repeat / warning 12 h); config rendered from the [repo template](../machines/gatekeeper/configs/alertmanager.yml.template) by [render-alertmanager.sh](../machines/gatekeeper/scripts/render-alertmanager.sh) — SMTP credential values live only in host `/srv/infra/.env` |
| Loki + Promtail | `127.0.0.1:3100` | tails `/var/log` + docker container logs **on gatekeeper only** |
| exporters | internal | node, cadvisor, nginx, blackbox — **all gatekeeper-local** |

**pyrite / ethics-gradient** run exporters only (compose files:
[pyrite/monitoring/](../machines/pyrite/monitoring/),
[ethics-gradient/monitoring/](../machines/ethics-gradient/monitoring/)) —
everything is scraped by the gatekeeper Prometheus; there is no local
collection or display. The postgreSQL-server project's local `prometheus` +
`grafana` pair was removed 2026-11-19 (its `postgres-exporter` was already
scraped centrally; its dashboard migrated to the central Grafana as
`postgres-main-overview`).

## What Prometheus scrapes (live target API, 2026-11-19 evening — all targets up)

| Job | Target | Covers |
|-----|--------|--------|
| prometheus / node-exporter / cadvisor / nginx | gatekeeper | host, containers, Caddy request rates |
| headscale | gatekeeper:9099 | tailnet control |
| logkeep-production | logkeep:8000 | app metrics |
| logkeep/bench-postgres-exporter | gatekeeper | app DBs |
| **pyrite-postgres-exporter** | `100.64.0.2:9187` | main multi-tenant PostgreSQL |
| **litellm-router** | `100.64.0.2:8505` (`/metrics/`) | **all Promptly inference**: per-model requests, tokens in/out, TTFT, latency, failures |
| **node-exporter-lan** | `100.64.0.2:9100`, `100.64.0.5:9100` | pyrite + ethics host CPU/RAM, per-device disk I/O, filesystem capacity, mdadm (RAID) counters, bcache (pyrite, `--collector.bcache`) |
| **cadvisor-lan** | `100.64.0.2:8180`, `100.64.0.5:8180` | pyrite + ethics containers |
| **dcgm-gpu-pyrite** | `100.64.0.2:9400` | 2× P100 util/temps/memory |
| **smartctl-pyrite** | `100.64.0.2:9633` | S.M.A.R.T. on all pyrite disks incl. the 15 TB array |
| **blackbox-tailnet** | 5 TCP probes | pyrite:8502 (LiteLLM), :5432 (postgres), :47302; ethics:8080 (model server); the-educator:25565 (Minecraft) |
| ssl-certs / ssl-certs-reachable | blackbox ×7 | 7 public HTTPS endpoints + cert expiry |

Policy: inference is monitored **at the gateway** (the LiteLLM router) — no
per-node llama.cpp scrapers or proxies. The ethics model server gets a TCP
liveness probe only.

## Alerts (alert-rules.yml)

Live groups: `logkeep_alerts` (app down, CPU/RAM/disk thresholds, pg
connections), `container_health_alerts` (**gatekeeper names only**:
logkeep/bench/headplane), `postgresql_alerts` (down/connections),
`ssl_certificate_alerts` (expiry + probe failures), `traffic_alerts`, and
`pyrite_storage_alerts` (added 2026-11-19, deliberately minimal):

| Alert | Severity | Fires when | For |
|-------|----------|-----------|-----|
| `StorageVolumeNearlyFull` | warning | `/mnt/arkk` or `/mnt/fast_scratch` < 10 % free | 30 m |
| `StorageVolumeCritical` | critical | same, < 5 % free | 10 m |
| `RaidArrayDegraded` | critical | `node_md_degraded > 0` (member disk down) | 5 m |
| `RaidArrayNotActive` | critical | array not in `active` state (covers the RAID-0 scratch array, which has no redundancy to "degrade") | 5 m |
| `DiskSmartFailed` | critical | `smartctl_device_smart_status != 1` (6 h scan cadence) | 10 m |

Anti-spam by design: only hard failure / almost-full conditions, long `for`
windows on slow-moving metrics, and the alertmanager repeat intervals
(warning 12 h, critical 4 h). No resync-progress, per-attribute SMART, or
I/O-rate alerts. **Still nothing** fires for promptly inference, GPU temps,
ethics host, or backup freshness — those metrics exist, the rules don't.

Note: the pre-existing generic `LowDiskSpace`/`CriticalDiskSpace` rules cover
`/` on every node-exporter host; they have been **firing on pyrite (root ~93 %
full) and ethics-gradient** since before this change.

## Dashboards (live Grafana, 2026-11-20)

| Dashboard | Source of truth | Notes |
|-----------|----------------|-------|
| Homelab Monitoring Overview | repo-provisioned | |
| **Gatekeeper: system resources** | [repo](../machines/gatekeeper/configs/monitoring/grafana-dashboards/gatekeeper-traffic-overview.json) | renamed from "Gatekeeper Traffic Overview" 2026-11-20; keeps the 7 Loki nginx-traffic panels and adds 12 node-exporter host panels (CPU/RAM/disk/net/swap/load). No per-container panels: gatekeeper's cadvisor only exposes host systemd cgroups |
| **LogKeep Production Monitoring** | [repo](../machines/gatekeeper/configs/monitoring/grafana-dashboards/logkeep-dashboard.json) | 11 panels; absorbed "LogKeep Traffic Monitoring" 2026-11-20 (all of that dashboard's panels were duplicates) — old uid `logkeep-traffic` removed |
| **Promptly: gateway traffic** | [repo](../machines/gatekeeper/configs/monitoring/grafana-dashboards/promptly-traffic-dashboard.json) | 5 SQL panels (gateway usage DB) + 4 **live** litellm panels: requests/h, tokens/h, avg TTFT, failures (all by model) |
| **PostgreSQL: main database (pyrite)** | [repo](../machines/gatekeeper/configs/monitoring/grafana-dashboards/postgres-main-overview.json) | migrated from the removed pyrite-local Grafana; every query pinned to `job="pyrite-postgres-exporter"` |
| **Pyrite: System Resources** (uid `pyrite-system-resources`) | [repo](../machines/gatekeeper/configs/monitoring/grafana-dashboards/pyrite-system-resources-dashboard.json) | 29 panels: CPU (usage by mode, load avg, RAM, swap), GPU (util/memory/temp/power, 2x P100 via DCGM 4.x metric names), storage (fs usage/capacity, per-device read/write rates, I/O utilization, bcache hit/free/dirty/bypass, mdadm state, S.M.A.R.T. temp + disk age). Renamed from the storage-only `pyrite-storage` dashboard 2026-11-19 |

Datasources: Prometheus, Loki, PostgreSQL (→ logkeep db; the Promptly dashboard
uses a second PG datasource pointing at the model-gateway usage db).

Note: the working Grafana admin credential is `GRAFANA_ADMIN_PASSWORD` in
`/srv/infra/.env` (confirmed 2026-11-20 against the live API). The
container's `GF_SECURITY_ADMIN_PASSWORD` env is a stale leftover that 401s —
don't chase it.

## Open holes

| Gap | Detail |
|-----|--------|
| **Alert rules** | Storage alerts live (2026-11-19, see above). Still no rules for: inference alive/TTFT/failure rate, GPU temp, ethics host down, backup freshness. (Root disk on pyrite/ethics IS covered — and firing, now actually delivered: SMTP credential fixed 2026-11-19.) SMART was actually broken until the `user: root` fix, 2026-11-19. |
| **Logs beyond gatekeeper** | Loki collects gatekeeper only; nothing ships from pyrite/ethics. |
| **Minecraft (the-educator)** | TCP liveness only; host not on tailnet, no node metrics. |
| **Backups** | No freshness check anywhere. |

## History

- 2026-11-19 (morning): audit wrote this page; dead `llamacpp-*` jobs found;
  pyrite/ethics exporter sets deployed; LiteLLM Prometheus callback enabled
  (dedicated tailnet-only metrics port 8505).
- 2026-11-19 (evening): per owner direction — dropped the dead `llamacpp-*`
  scrape jobs and any per-node inference scraping; `litellm-router` job is the
  single inference target. Removed the pyrite-local prometheus/grafana silo;
  migrated its dashboard. Promptly dashboard's 4 dead panels replaced with
  verified litellm queries.
- 2026-11-19 (night): discovered the pyrite smartctl exporter was blind (image
  defaults to `USER=nobody`; device-file DAC bits aren't bypassed by
  capabilities) — fixed with `user: root`, all 828 S.M.A.R.T. attribute series
  now flowing. Added the `pyrite-storage` dashboard (fs capacity, per-device
  I/O, bcache, mdadm, S.M.A.R.T.); every query validated against live central
  Prometheus before deploy. Documented pyrite storage layout (RAID-5 `/mnt/arkk`,
  bcache `md0`+NVMe `/mnt/fast_scratch`) in the ops inventory.
- 2026-11-19 (later): generalized the storage dashboard to
  `pyrite-system-resources` per owner request — 29 panels now covering CPU
  (usage by mode, load, RAM, swap), GPU (2x P100: util/memory/temp/power via
  DCGM 4.x metric names), and the original storage section. All 36 expressions
  pre-validated against live central Prometheus; old uid `pyrite-storage`
  deleted from Grafana on file removal. Also found the dcgm-exporter is
  healthy — the earlier "no GPU metrics" impression came from querying legacy
  3.x metric names (`DCGM_FI_DEV_GPU_UTIL` etc.) that no longer exist in
  dcgm-exporter 4.x.
- 2026-11-19 (SMTP fix): email alerts had been silently failing since at
  least 2026-11-16 — IONOS started rejecting the inline SMTP password (535
  on every attempt) after 2FA was enabled on the IONOS account. Owner
  generated an app password. Consolidated credential storage: all live
  values now live only in host `/srv/infra/.env` (`chmod 600`); the
  plaintext inline value in `alertmanager.yml` and the repo's
  secret-bearing mirror of it were removed (the mirror had held the old
  password since the docs migration). Because the distroless alertmanager
  image and its config parser do not expand `$VAR`, the live yml is now a
  **rendered artifact**: `scripts/render-alertmanager.sh` (envsubst) bakes
  values from `.env` into the mounted file, which the container hot-reloads.
  Verified end-to-end: raw STARTTLS login succeeded with the `.env`
  credential, and a test alert through the Alertmanager API delivered with
  no 535s in the logs.
