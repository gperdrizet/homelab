# Monitoring Inventory (Gatekeeper + Pyrite)

Snapshot date: 2026-07-12 (post-cleanup update)

## Monitoring architecture

- Central metrics, dashboards, alerting, and logs run on gatekeeper.
- Pyrite now exposes exporter endpoints (currently postgres-exporter) and is
  scraped over tailnet.
- Local pyrite Grafana/Prometheus have been stopped as part of consolidation.

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

Service-specific exporters observed:
- `logkeep-postgres-exporter`
- `bench-postgres-exporter`

## Pyrite monitoring-related services

Active exporter:
- `postgres-exporter` on `100.64.0.2:9187`

Not part of active pyrite monitoring plane anymore:
- local `prometheus` (stopped)
- local `grafana` (stopped)

## Active Prometheus scrape inventory (gatekeeper)

Current active jobs discovered from Prometheus targets API include:
- `prometheus`
- `node-exporter`
- `cadvisor`
- `nginx`
- `headscale`
- `logkeep-postgres-exporter`
- `bench-postgres-exporter`
- `pyrite-postgres-exporter`
- `logkeep-production`
- `ssl-certs`
- `ssl-certs-reachable`

Current target health snapshot highlights:
- Up: all active scrape targets above, including `logkeep-production`,
  `logkeep-postgres-exporter`, and `pyrite-postgres-exporter`.
- Obsolete LogKeep variant scrape jobs were removed from active configuration.
- Retired `code.perdrizet.org` reachability probe was removed from
  `ssl-certs-reachable`.

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
- Confirmed current `vhost` label values include:
  `admin`, `code`, `grafana`, `headplane`, `jupyter`, `logkeep`,
  and `promptlyapi`.

## What this means for pageviews and API requests

- Yes, traffic and request monitoring is available beyond database metrics.
- Prometheus handles infrastructure and exporter metrics (host health,
  container health, postgres exporters, scrape/probe metrics).
- Loki handles request-level log analytics (request counts, error rates,
  top endpoints, and per-vhost traffic patterns).
- If a service emits app metrics at `/metrics` (for example LogKeep),
  Prometheus can also collect app-level request metrics directly.

Current limitations:
- Request-level telemetry quality depends on nginx/app log format.
- True product analytics (sessions, users, funnels) are not currently tracked.
- Most services are monitored at reverse-proxy/log level unless they expose
  dedicated app metrics.

## Cleanup tasks queued

1. Add pyrite host/container telemetry if desired (`node-exporter`, `cadvisor`,
   optional promtail) and wire to gatekeeper Prometheus/Loki.
2. Add service-specific dashboards to match real jobs and remove obsolete panels.

## Dashboards

New dashboard added in this repo:
- `docs/machines/gatekeeper/configs/monitoring/grafana-dashboards/homelab-monitoring-overview.json`
- `docs/machines/gatekeeper/configs/monitoring/grafana-dashboards/gatekeeper-traffic-overview.json`

Focus:
- scrape health
- target counts up/down
- scrape duration
- postgres exporter health (including pyrite)
- endpoint probe success