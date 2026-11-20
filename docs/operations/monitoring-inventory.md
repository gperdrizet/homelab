# Monitoring Inventory (Gatekeeper + Pyrite)

Snapshot date: 2026-11-19 (live-checked: Prometheus target API, container
inventory on both hosts)

## Monitoring architecture

- Single plane: central metrics, dashboards, alerting, and logs run on
  gatekeeper. There is no other Prometheus or Grafana in the fleet.
- Pyrite and ethics-gradient expose tailnet-bound exporter endpoints only and
  are scraped by the gatekeeper Prometheus.
- The `postgreSQL-server` project's local prometheus/grafana pair (the last
  silo, on `100.64.0.2:9090`/`:3000`) was removed 2026-11-19; its
  postgres-exporter was already part of the central plane and its dashboard
  migrated to the central Grafana (`postgres-main-overview`).
- Inference is monitored at the gateway: the LiteLLM router on pyrite
  (`100.64.0.2:8505`) is the single inference scrape target. No per-node
  llama.cpp scraping (owner decision).

## How the monitoring stack works

1. Services expose telemetry:
  - exporters expose Prometheus metrics (`/metrics`)
  - nginx and container logs are written to files/json logs
2. Collection:
  - Prometheus scrapes metrics on a fixed interval (15s)
  - Promtail tails logs and pushes them to Loki (gatekeeper logs only)
  - Blackbox exporter probes HTTPS endpoints for reachability/TLS health and
    tailnet TCP ports for liveness
3. Storage and query:
  - Prometheus stores time-series metrics (30-day retention)
  - Loki stores structured logs for log/traffic queries
4. Visualization and alerting:
  - Grafana reads from Prometheus and Loki dashboards
  - Alertmanager routes alert notifications from Prometheus rules

## Gatekeeper monitoring stack (containers)

Core observability services:
- `monitoring-prometheus`
- `monitoring-grafana`
- `monitoring-alertmanager`
- `monitoring-loki`
- `monitoring-promtail`

Exporters/probes:
- `monitoring-node-exporter`
- `monitoring-cadvisor`
- `monitoring-nginx-exporter`
- `monitoring-blackbox-exporter`

Service-specific exporters:
- `logkeep-postgres-exporter`
- `bench-postgres-exporter`

Live config paths (host-side, mounted into the containers):
- Prometheus: `/srv/infra/configs/prometheus.yml`
- Alertmanager: `/srv/infra/configs/alertmanager.yml`
- Alert rules: `/srv/infra/configs/alert-rules.yml`
- Grafana datasources: `/srv/infra/configs/grafana-datasources.yml`
- Grafana dashboards: `/srv/infra/configs/grafana-dashboards/`

## Pyrite / ethics-gradient monitoring-related services

Active exporters, scraped over tailnet:

pyrite (`100.64.0.2`):
- `obs-node-exporter` on `:9100` — host CPU/RAM/disk, per-device I/O, filesystem
  capacity, mdadm (RAID) counters, bcache (collected via
  `--collector.mdadm --collector.bcache`; runs as user `nobody`)
- `obs-cadvisor` on `:8180` — containers
- `obs-dcgm-exporter` on `:9400` — 2× Tesla P100 (util, temps, memory)
- `obs-smartctl-exporter` on `:9633` — full S.M.A.R.T. on all 10 disks
  (temperature, power-on hours, reallocated/pending sectors, error-log count).
  Must run as `user: root` — the image defaults to `USER=nobody`, which cannot
  open `/dev/sd*` (device-file DAC bits are not bypassed by capabilities,
  even when privileged); discovered 2026-11-19 when only 2 of ~800 metrics
  came through. Scans every 6 h (`--smartctl.interval=21600s`).
- `postgres-exporter` on `:9187` — the main multi-tenant PostgreSQL
- `litellm-router` on `:8505` — dedicated metrics port (no auth, tailnet-only
  publish); inference metrics for all Promptly traffic

ethics-gradient (`100.64.0.5`):
- `obs-node-exporter` on `:9100`
- `obs-cadvisor` on `:8180`
- its model server (`:8080`) gets a blackbox TCP liveness probe only

Compose sources: [machines/pyrite/monitoring/](../machines/pyrite/monitoring/)
and [machines/ethics-gradient/monitoring/](../machines/ethics-gradient/monitoring/).

### Pyrite storage layout (what the exporters cover)

- `/` — `sde2`, 440 GB ext4 (447 GB "FATTYDOVE" SSD). Was at ~93 % on
  2026-11-19; watched by the storage dashboard.
- `/mnt/arkk` — `md127`, **RAID-5 of 5× 3.6 TB** ST4000 (sda/sdc/sdg/sdh/sdi),
  15 TB xfs, the main data volume and NFS export. mdadm metrics:
  `node_md_state`, `node_md_degraded`, `node_md_disks`, `node_md_blocks_synced`.
- `/mnt/fast_scratch` — `bcache0` (models + fast scratch): **bcache in front of
  `md0`, a RAID-0 of 3× 1 TB** (sdb/sdd/sdf), with a **1 TB NVMe**
  (nvme0n1, Sabrent Rocket Q) as the cache device. 2.7 TB ext4. bcache sysfs
  (`/sys/fs/bcache`) is kernel-managed (no fstab entry needed). bcache metrics
  (node-exporter `--collector.bcache`): hit/miss totals, `cache_available_percent`,
  `dirty_data_bytes`, `bypassed_bytes_total`, `writeback_rate`.
- Per-device I/O for all of the above: `node_disk_read_bytes_total`,
  `node_disk_written_bytes_total`, `node_disk_io_time_seconds_total`,
  `node_disk_io_now` (diskstats collector); filesystem size/avail for every
  mount (filesystem collector).

## Grafana datasources

Four datasources are provisioned (`/srv/infra/configs/grafana-datasources.yml`):
- `Prometheus` - default datasource, `http://monitoring-prometheus:9090`
- `Loki` - `http://monitoring-loki:3100`
- `PostgreSQL` - direct connection to `logkeep-postgres:5432`, database
  `logkeep`
- `Promptly` - direct connection to `model-gateway-db:5432`, database
  `gateway`, read-only `grafana_ro` role (only `usage_events` and `users`
  grants)

Both Postgres datasources set the default database in **both** the top-level
`database:` field and `jsonData.database` - the current Grafana version
(12.3) reads the default database for query/SQL-builder validation from
`jsonData.database`, while the top-level field is still used for the
connection itself. Both must be kept in sync if either datasource is edited.

## Active Prometheus scrape inventory (gatekeeper)

Active jobs (all targets up as of 2026-11-19):
- `prometheus`
- `node-exporter` (gatekeeper)
- `cadvisor` (gatekeeper)
- `nginx`
- `headscale`
- `logkeep-postgres-exporter`
- `bench-postgres-exporter`
- `pyrite-postgres-exporter` (`100.64.0.2:9187`)
- `litellm-router` (`100.64.0.2:8505`, `metrics_path: /metrics/`)
- `node-exporter-lan` (`100.64.0.2:9100`, `100.64.0.5:9100`)
- `cadvisor-lan` (`100.64.0.2:8180`, `100.64.0.5:8180`)
- `dcgm-gpu-pyrite` (`100.64.0.2:9400`)
- `smartctl-pyrite` (`100.64.0.2:9633`)
- `blackbox-tailnet` (TCP: pyrite:8502/5432/47302, ethics:8080, the-educator:25565)
- `ssl-certs`
- `ssl-certs-reachable`

Removed 2026-11-19: `llamacpp-pyrite`, `llamacpp-pyrite-batch`,
`llamacpp-ethics` (pre-migration llama.cpp `/metrics` scrapers; inference is
now covered by `litellm-router`).

## Dashboards

Provisioned dashboards (`/srv/infra/configs/grafana-dashboards/`):
- `gatekeeper-traffic-overview.json`
- `traffic-monitoring.json`
- `promptly-traffic-dashboard.json` (aka "Promptly: gateway traffic",
  uid `promptly-gateway-traffic`)
- `homelab-monitoring-overview.json`
- `logkeep-dashboard.json`
- `postgres-main-overview.json` (aka "PostgreSQL: main database (pyrite)",
  uid `postgres-main-overview`)
- `pyrite-system-resources-dashboard.json` (aka "Pyrite: System Resources
  (CPU / RAM / GPU / Storage)", uid `pyrite-system-resources`) — 29 panels:
  top stats (CPU/RAM/GPU0/GPU1 util, RAID degraded, SMART, fs usage, load
  avg, SMART error logs), CPU usage by mode + load avg, memory + swap, GPU
  util/memory/temp/power, then the original storage section (fs
  capacity, per-device read/write, I/O utilization, bcache hit/free/dirty/
  bypass, mdadm state, S.M.A.R.T. temp + disk age). Renamed from the
  storage-only dashboard 2026-11-19; all 36 expressions pre-validated live
  before deploy; old uid `pyrite-storage` removed from Grafana (deletion
  allowed by the file provider). Note: DCGM metrics use the 4.x names
  (`*_UTIL_RATIO` 0–1, `*_TEMP_CELSIUS`, `*_FB_*_BYTES`,
  `DCGM_FI_DEV_BOARD_POWER_WATTS`) — the legacy `DCGM_FI_DEV_GPU_UTIL` /
  `DCGM_FI_DEV_FB_USED` names no longer exist.

The promptly dashboard has 9 panels:
- 5 Postgres-backed (via the `Promptly` datasource): `Requests per hour`,
  `Tokens per hour (input + output)`, `New accounts per day`,
  `Requests today`, `New accounts today`.
- 4 Prometheus-backed (litellm, replaced the dead llama.cpp panels
  2026-11-19): `Inference requests per hour (by model)` (on
  `litellm_deployment_total_requests_total`, label `model_group`),
  `Tokens per hour (by model)` (input + output, label `model`),
  `Time to first token (avg seconds, by model)`, `Failed inference requests
  (per 15m, by model)`. Note the label mismatch between metric families
  (`model_group` vs `model`).

Focus of `homelab-monitoring-overview.json`/`gatekeeper-traffic-overview.json`:
- scrape health
- target counts up/down
- scrape duration
- postgres exporter health (including pyrite)
- endpoint probe success

The `postgres-main-overview` dashboard queries are all pinned to
`job="pyrite-postgres-exporter"` because three postgres exporters run in
Prometheus (main DB, logkeep, bench).

## What is being monitored right now

Host and container telemetry:
- Gatekeeper host + containers (node-exporter, cadvisor)
- Pyrite host (incl. RAID counters), 2× P100 GPUs, all disks (SMART), containers
- Ethics-gradient host + containers

Storage telemetry (pyrite):
- Filesystem capacity/usage for `/`, `/mnt/arkk`, `/mnt/fast_scratch`
  (`node_filesystem_*`)
- Per-device read/write rates, I/O utilization, in-flight I/O
  (`node_disk_*`, all members of both arrays + NVMe + root disk)
- bcache: hit ratio, cache free %, dirty data (writeback), bypass rate
  (`node_bcache_*`)
- RAID: array state, degraded members, resync progress (`node_md_*`)
- Full S.M.A.R.T. per disk: status, temperature, power-on hours, reallocated
  and pending sectors, error-log count (`smartctl_device_*`)

Database telemetry:
- Main multi-tenant PostgreSQL on pyrite (over tailnet)
- Bench postgres exporter
- LogKeep postgres exporter

Inference:
- LiteLLM router: per-model request counters, input/output tokens, TTFT,
  latency, failure rates — the full Promptly path (gateway → router → hosts)

Service/application telemetry:
- LogKeep production app metrics (`/metrics`)
- Headscale control plane

Availability and certificate probes:
- HTTPS probe jobs via blackbox exporter (`ssl-certs`, `ssl-certs-reachable`)
- TCP liveness: LiteLLM, pyrite postgres, ethics model server, Minecraft

Logs:
- Loki + promtail on gatekeeper (gatekeeper logs only)

HTTP/API traffic:
- Nginx access logs are collected by promtail and stored in Loki.
- Parsed fields include `method`, `path`, `status`, `remote_addr`, and
  `vhost` (derived from nginx access log filename where available).
- This supports per-service request volume and status code tracking for
  gatekeeper-hosted domains.
- Current `vhost` label values include: `admin`, `code`, `grafana`,
  `headplane`, `jupyter`, `logkeep`, and `promptlyapi`.

## What this means for pageviews and API requests

- Traffic and request monitoring is available beyond database metrics.
- Prometheus handles infrastructure and exporter metrics (host health,
  container health, GPU/disk health, postgres exporters, inference,
  scrape/probe metrics).
- Loki handles request-level log analytics (request counts, error rates,
  top endpoints, and per-vhost traffic patterns).
- If a service emits app metrics at `/metrics` (for example LogKeep,
  LiteLLM), Prometheus also collects app-level request metrics directly.

Current limitations:
- Request-level telemetry quality depends on nginx/app log format.
- True product analytics (sessions, users, funnels) are not currently tracked.
- Loki does not ship logs from pyrite/ethics-gradient.
- Most services are monitored at reverse-proxy/log level unless they expose
  dedicated app metrics.

## Alert rules (`/srv/infra/configs/alert-rules.yml`)

Live groups: `logkeep_alerts`, `container_health_alerts` (gatekeeper names
only), `postgresql_alerts`, `ssl_certificate_alerts`, `traffic_alerts`, and
**`pyrite_storage_alerts`** (added 2026-11-19, deliberately minimal — only hard
failure / almost-full conditions, no resync-progress or per-attribute SMART
noise):

| Alert | Severity | Expression (simplified) | `for` |
|-------|----------|-------------------------|-------|
| `StorageVolumeNearlyFull` | warning | `/mnt/arkk` or `/mnt/fast_scratch` avail < 10 % | 30 m |
| `StorageVolumeCritical` | critical | same, avail < 5 % | 10 m |
| `RaidArrayDegraded` | critical | `node_md_degraded > 0` (member disk down) | 5 m |
| `RaidArrayNotActive` | critical | `node_md_state{state="active"} == 0` (matters for the RAID-0 scratch array, which has no redundancy to degrade) | 5 m |
| `DiskSmartFailed` | critical | `smartctl_device_smart_status != 1` (6 h SMART scan cadence) | 10 m |

Routing: critical → `email-critical` (4 h repeat), warning → `email-alerts`
(12 h repeat), both to george@perdrizet.org. Every expression was validated
against live central Prometheus before deploy (all returned the expected
empty result while healthy); group reloaded via `POST :9090/-/reload` and
confirmed loaded with no evaluation errors.

Pre-existing generic `LowDiskSpace`/`CriticalDiskSpace` rules cover `/` on
every node-exporter host and have been **firing on pyrite (root ~93 % full)
and ethics-gradient** — that is the existing root-disk coverage the owner
already receives.

## Open tasks

1. Alert rules for the *remaining* new targets: inference alive/TTFT/failure
   rate, GPU temps, ethics host, backup freshness. (Storage rules live since
   2026-11-19; root disk already covered by the generic rules. Optional
   future: SMART `reallocated/pending sector` growth as an early-warning
   signal before `smart_status` flips — deliberately not added to keep the
   alert set minimal.)
2. Ship pyrite/ethics logs to Loki if log coverage there matters.
3. Reconcile the Grafana admin password: `GF_SECURITY_ADMIN_PASSWORD` in
   `/srv/infra/.env` no longer matches the initialized DB (API returns 401).
