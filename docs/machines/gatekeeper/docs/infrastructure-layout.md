# Gatekeeper infrastructure layout

Current-state file and runtime layout for gatekeeper.

Last verified: 2026-07-12

## Host role

- Public ingress and TLS termination (nginx)
- Monitoring control plane (Prometheus, Grafana, Loki, Alertmanager)
- Public app host for LogKeep, Bench, Promptly API, Bug Hunter, Feedback
- Tailnet control services (Headscale + Headplane)

## Core paths

| Path | Purpose |
|------|---------|
| `/srv/infra/` | monitoring stack compose, monitoring configs, monitoring data |
| `/etc/nginx/` | nginx runtime config (`conf.d`, stream proxy in `nginx.conf`) |
| `/opt/logkeep/` | LogKeep production stack |
| `/opt/bench/` | Bench production stack |
| `/opt/model-gateway/` | Promptly/model-gateway stack |
| `/opt/feedback/` | Feedback app stack |
| `/opt/bug-hunter/` | Bug Hunter production stack |
| `/opt/*-staging/` | staging stacks retained where still used |

## Monitoring paths

| Path | Purpose |
|------|---------|
| `/srv/infra/docker-compose.monitoring.yml` | monitoring stack definition |
| `/srv/infra/configs/prometheus.yml` | scrape and probe config |
| `/srv/infra/configs/alert-rules.yml` | alert rules |
| `/srv/infra/configs/promtail-config.yml` | log shipping config |
| `/srv/infra/configs/grafana-datasources.yml` | Grafana datasource provisioning |
| `/srv/infra/configs/grafana-dashboards/` | provisioned dashboard JSON files |
| `/srv/infra/data/monitoring/` | persistent monitoring data volumes |

## Nginx vhost model

Active nginx vhost files are under `/etc/nginx/conf.d/`.

Current active public endpoints include:
- `logkeep.perdrizet.org`
- `bench.perdrizet.org`
- `bug-hunter.perdrizet.org`
- `feedback.perdrizet.org`
- `admin.perdrizet.org`
- `promptlyapi.com`
- `grafana.perdrizet.org`
- `headscale.perdrizet.org`
- `headplane.perdrizet.org`
- `jupyter.perdrizet.org`

Configured/limited-use endpoints retained in nginx:
- `staging.perdrizet.org`
- `site-staging.perdrizet.org`
- `code.perdrizet.org`
- `model.perdrizet.org` (redirect to promptlyapi.com)

## Cross-machine dependencies

- Jupyter backend on pyrite: `100.64.0.2:47302`
- PostgreSQL stream proxy: public `:54321` -> `100.64.0.2:5432`
- Promptly API forwards model traffic to pyrite llama.cpp

## Notes

- This document is current-state only.
- Historical migration phases are intentionally excluded.
