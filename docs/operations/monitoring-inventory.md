# Monitoring Inventory (Gatekeeper + Pyrite)

Snapshot date: 2026-09-09

## Monitoring architecture

- Central metrics, dashboards, alerting, and logs run on gatekeeper.
- Pyrite exposes exporter endpoints (`pyrite-postgres-exporter`,
  `llamacpp-pyrite`, `llamacpp-pyrite-batch`) and is scraped over tailnet.
- Pyrite also runs a separate local Grafana/Prometheus/postgres-exporter
  stack. It is **not** part of the homelab monitoring plane - it belongs to
  the unrelated `postgreSQL-server` teaching/demo project
  (https://github.com/gperdrizet/postgreSQL-server, deployed at
  `~/postgreSQL-server` on pyrite). It is bound to the tailnet IP
  (`100.64.0.2`) only, not the LAN.

## How the monitoring stack works

1. Services expose telemetry:
  - exporters expose Prometheus metrics (`/metrics`)
  - nginx and container logs are written to files/json logs
2. Collection:
  - Prometheus scrapes metrics on a fixed interval (15s)
  - Promtail tails logs and pushes them to Loki
  - Blackbox exporter probes HTTPS endpoints for reachability/TLS health
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

## Pyrite monitoring-related services

Active exporters, scraped over tailnet:
- `pyrite-postgres-exporter` on `100.64.0.2:9187`
- `llamacpp-pyrite` (llama.cpp's built-in `/metrics`) on `100.64.0.2:8502` -
  the **production** `llamacpp.service`. This is intentionally stopped
  whenever a batch/offline inference job needs both GPUs, at which point this
  target goes down. Restart `llamacpp.service` on pyrite once the batch job
  finishes to bring it back.
- `llamacpp-pyrite-batch` scrapes the two overnight batch throughput
  instances: `pyrite-batch1` (`100.64.0.2:8503`) and `pyrite-batch2`
  (`100.64.0.2:8504`). These are only up while a batch job is running.

Not part of the homelab monitoring plane (separate project, see above):
- local `prometheus` (tailnet-bound, `postgreSQL-server` project)
- local `grafana` (tailnet-bound, `postgreSQL-server` project)
- local `postgres-exporter` (tailnet-bound, `postgreSQL-server` project)

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

Active jobs:
- `prometheus`
- `node-exporter`
- `cadvisor`
- `nginx`
- `headscale`
- `logkeep-postgres-exporter`
- `bench-postgres-exporter`
- `pyrite-postgres-exporter`
- `llamacpp-pyrite`
- `llamacpp-pyrite-batch`
- `logkeep-production`
- `ssl-certs`
- `ssl-certs-reachable`

Target health notes:
- All targets are up except `llamacpp-pyrite`, which tracks whether the
  production `llamacpp.service` on pyrite is running (see above - it is
  intentionally stopped during batch inference jobs).
- `llamacpp-pyrite` and `llamacpp-pyrite-batch` both authenticate with the
  same Bearer API key (from `~/llama.cpp/.env` on pyrite) and scrape
  `/metrics`. Targets carry a `slot` label (`production` or `batch`) and a
  distinct `instance` label per running server
  (`pyrite`/`pyrite-batch1`/`pyrite-batch2`).

## Dashboards

Provisioned dashboards (`/srv/infra/configs/grafana-dashboards/`):
- `gatekeeper-traffic-overview.json`
- `traffic-monitoring.json`
- `promptly-traffic-dashboard.json` (aka "Promptly: gateway traffic",
  uid `promptly-gateway-traffic`)
- `homelab-monitoring-overview.json`
- `logkeep-dashboard.json`

The promptly dashboard has 9 panels:
- 5 Postgres-backed (via the `Promptly` datasource): `Requests per hour`,
  `Tokens per hour (input + output)`, `New accounts per day`,
  `Requests today`, `New accounts today`.
- 4 Prometheus-backed: `llama.cpp: prompt/generation throughput (tok/s)`,
  `llama.cpp: slot state`, `llama.cpp: decode() call rate`,
  `llama.cpp: largest observed context (tokens)`. These match
  `instance=~"pyrite.*"`, so each shows a series per currently-running
  llama.cpp instance (production and/or either batch slot), labeled by
  instance in the legend. They have data whenever any llama.cpp instance is
  running, not just production.

Focus of `homelab-monitoring-overview.json`/`gatekeeper-traffic-overview.json`:
- scrape health
- target counts up/down
- scrape duration
- postgres exporter health (including pyrite)
- endpoint probe success

## What is being monitored right now

Host and container telemetry:
- Gatekeeper host metrics via `node-exporter`
- Gatekeeper container metrics via `cadvisor`
- Gatekeeper nginx metrics via `nginx-exporter`

Database telemetry:
- Bench postgres exporter
- LogKeep postgres exporter
- Pyrite postgres exporter over tailnet

Service/application telemetry:
- LogKeep production app metrics (`/metrics`)
- llama.cpp production + batch instances on pyrite (`/metrics`)

Availability and certificate probes:
- HTTPS probe jobs via blackbox exporter (`ssl-certs`, `ssl-certs-reachable`)

Logs:
- Loki + promtail on gatekeeper

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
  container health, postgres exporters, scrape/probe metrics).
- Loki handles request-level log analytics (request counts, error rates,
  top endpoints, and per-vhost traffic patterns).
- If a service emits app metrics at `/metrics` (for example LogKeep,
  llama.cpp), Prometheus also collects app-level request metrics directly.

Current limitations:
- Request-level telemetry quality depends on nginx/app log format.
- True product analytics (sessions, users, funnels) are not currently tracked.
- Most services are monitored at reverse-proxy/log level unless they expose
  dedicated app metrics.

## Open tasks

1. Add pyrite host/container telemetry if desired (`node-exporter`, `cadvisor`,
   optional promtail) and wire to gatekeeper Prometheus/Loki.
2. Add service-specific dashboards to match real jobs and remove obsolete panels.
3. Restart production `llamacpp.service` on pyrite once the current overnight
   batch job finishes, to restore the `llamacpp-pyrite` scrape target.