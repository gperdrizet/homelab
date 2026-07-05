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

See [docs/services.md](docs/services.md) for full service/port/domain inventory and
[docs/infrastructure-layout.md](docs/infrastructure-layout.md) for the directory layout.

---

## VPS Infrastructure consolidation status

Homelab is the canonical source of truth for gatekeeper operations.

The external `vps-infrastructure` repository is being folded into this repo and
is treated as a migration source during consolidation.

Primary gatekeeper assets in this repo:

- Compose and infra files: `docs/machines/gatekeeper/compose/`,
  `docs/machines/gatekeeper/docker-compose.*.yml`
- Configurations: `docs/machines/gatekeeper/configs/`
- Scripts: `docs/machines/gatekeeper/scripts/`
- Tailnet assets: `docs/machines/gatekeeper/tailnet/`
- Operational docs: `docs/machines/gatekeeper/docs/`

Continue to update the homelab paths above first; mirror from external sources
only while migration remains in progress.

## Canonical runbooks

- Service and domain inventory:
  [docs/services.md](docs/services.md)
- Runtime layout and container placement:
  [docs/infrastructure-layout.md](docs/infrastructure-layout.md)
- Backup operational notes:
  [docs/backup-improvements.md](docs/backup-improvements.md)
- Implementation and migration notes:
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

## Deprecated source note

The external `vps-infrastructure` repository remains a historical migration
source only. Net-new operational updates should be authored in this repo under
`docs/machines/gatekeeper/`.
