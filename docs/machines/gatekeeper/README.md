# gatekeeper

VPS running public-facing services, nginx reverse proxy, Tailscale exit node, and monitoring stack.

---

## Hardware

**Provider:** Ionos VPS  
**Public IP:** 74.208.107.78  
**OS:** Ubuntu (LTS)  
**RAM:** 8 GB  
**Disk:** SSD (provider-managed)  
**SSH port:** 44441  

---

## Role

- Public reverse proxy (nginx): terminates TLS for all services
- Hosts multiple web applications in Docker (logkeep, bench, bug-hunter, feedback, model-gateway, nixx, etc.)
- Monitoring stack (Prometheus, Grafana, Loki, Alertmanager)
- Tailscale exit node and Headscale control server
- TCP proxy to pyrite's PostgreSQL (port 54321)

---

## Contents

See [docs/services.md](docs/services.md) for the full service/port/domain inventory and
[docs/infrastructure-layout.md](docs/infrastructure-layout.md) for the directory layout.

## Repository layout

All gatekeeper operational assets live in this repo:

| Asset | Location |
|-------|----------|
| Core + monitoring compose files | `docker-compose.core.yml`, `docker-compose.monitoring.yml` |
| App compose files (logkeep, bench, btcpay) | `compose/` |
| nginx, monitoring, alertmanager configs | `configs/` — see [nginx README](configs/nginx/README.md) |
| Setup, deploy, health-check scripts | `scripts/` |
| Headscale/Tailscale setup | [tailnet/README.md](tailnet/README.md) |
| Runbooks and reference docs | [docs/services.md](docs/services.md), [docs/infrastructure-layout.md](docs/infrastructure-layout.md) |

## Runbooks

- Service and domain inventory: [docs/services.md](docs/services.md)
- Runtime layout and container placement: [docs/infrastructure-layout.md](docs/infrastructure-layout.md)
- Backup operations: [docs/backup-improvements.md](docs/backup-improvements.md)
- nginx configuration model: [configs/nginx/README.md](configs/nginx/README.md)
- Tailnet setup: [tailnet/README.md](tailnet/README.md)
- Incidents and resilience: [docs/incidents.md](docs/incidents.md)

Historical records (April 2026 VPS reorganization):
[docs/IMPLEMENTATION-GUIDE.md](docs/IMPLEMENTATION-GUIDE.md),
[docs/phase3-summary.md](docs/phase3-summary.md)

## Operational conventions

- Routing model: gatekeeper proxies to pyrite over Tailscale where required.
- Developer endpoints:
  `code.perdrizet.org` -> `100.64.0.2:47301`,
  `jupyter.perdrizet.org` -> `100.64.0.2:47302`.
- Public PostgreSQL path:
  nginx TCP stream `:54321` -> `100.64.0.2:5432`.
- Secrets policy:
  no secret values in git; follow [../../secrets/README.md](../../secrets/README.md).
