# Gatekeeper service inventory

Current-state inventory for gatekeeper (74.208.107.78).

Last verified against runtime and nginx config: 2026-07-12

## Public-facing ports

| Port | Protocol | Service | Notes |
|------|----------|---------|-------|
| 80 | TCP | nginx | HTTP -> HTTPS redirects |
| 443 | TCP | nginx | TLS termination for public domains |
| 44441 | TCP | sshd | primary SSH listener |
| 54321 | TCP | nginx stream proxy | public PostgreSQL proxy to `100.64.0.2:5432` |

## Active HTTPS domains on nginx

| Domain | Backend | State | Notes |
|--------|---------|-------|-------|
| perdrizet.org | redirect | active | redirects to logkeep |
| www.perdrizet.org | redirect | active | redirects to logkeep |
| logkeep.perdrizet.org | `127.0.0.1:8000` | active | LogKeep production |
| bench.perdrizet.org | `127.0.0.1:8010` | active | Bench production |
| bug-hunter.perdrizet.org | `127.0.0.1:8509` | active | Bug Hunter frontend |
| feedback.perdrizet.org | `127.0.0.1:18080` | active | Feedback app |
| admin.perdrizet.org | `127.0.0.1:8600` | active | perdrizet-admin systemd service |
| promptlyapi.com | `127.0.0.1:8503` | active | model-gateway API |
| model.perdrizet.org | redirect | active | redirects to promptlyapi.com |
| grafana.perdrizet.org | `127.0.0.1:3000` | active | Grafana |
| headscale.perdrizet.org | `127.0.0.1:8090` | active | Headscale API |
| headplane.perdrizet.org | `127.0.0.1:3001` | active | Headscale UI |
| jupyter.perdrizet.org | `100.64.0.2:47302` | active | JupyterLab on pyrite |
| nixx.perdrizet.org | `100.64.0.2:8000` | configured | pyrite service currently inactive |
| staging.perdrizet.org | `100.64.0.1:8003` | configured | auth-gated staging endpoint |
| site-staging.perdrizet.org | static root | configured | staging static site endpoint |
| code.perdrizet.org | `100.64.0.2:47301` | configured | legacy OpenVSCode endpoint; not part of active pyrite service model |

## Monitoring stack (gatekeeper)

Managed by `/srv/infra/docker-compose.monitoring.yml`.

| Container | Function |
|-----------|----------|
| monitoring-prometheus | metrics scrape + TSDB |
| monitoring-grafana | dashboards and visualization |
| monitoring-loki | log storage |
| monitoring-promtail | log shipping |
| monitoring-alertmanager | alert routing |
| monitoring-node-exporter | host metrics |
| monitoring-cadvisor | container metrics |
| monitoring-nginx-exporter | nginx metrics |
| monitoring-blackbox-exporter | HTTPS/TLS probes |

## Application/runtime containers (high-level)

### LogKeep
- `logkeep` (production app)
- `logkeep-postgres`
- `logkeep-postgres-exporter`
- `logkeep-postgres-staging` (staging DB remains present)

### Bench
- `bench-web`, `bench-celery`, `bench-celery-beat`
- `bench-postgres`, `bench-redis`
- `bench-postgres-exporter`
- staging bench containers are present

### Model gateway
- `model-gateway-api`, `model-gateway-db` (production)
- `model-gateway-db-staging` present

### Other apps
- `feedback-*` containers
- `bug-hunter-*` containers (production + partial staging)

## Tailnet integration

- gatekeeper tailnet IP: `100.64.0.1`
- pyrite tailnet IP: `100.64.0.2`
- PostgreSQL public proxy path: `:54321` -> `100.64.0.2:5432`
- Jupyter ingress path: `jupyter.perdrizet.org` -> `100.64.0.2:47302`

## Notes

- This file is intentionally current-state only.
- Migration notes and phase summaries are not tracked here.
