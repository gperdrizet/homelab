!!! note "Superseded as the master inventory"
    The cross-host service inventory now lives at
    [services/README.md](../../../services/README.md). This page remains the
    gatekeeper-specific detail view; update both when services change, or
    fold into the services pages once verified.

# Gatekeeper service inventory

Current-state inventory for gatekeeper (74.208.107.78).

Last verified against runtime and nginx config: 2026-11-20;
Jitsi Meet + Forgejo sections verified live 2026-11-27.

## Public-facing ports

| Port | Protocol | Service | Notes |
|------|----------|---------|-------|
| 80 | TCP | nginx | HTTP -> HTTPS redirects |
| 443 | TCP | nginx | TLS termination for public domains |
| 44441 | TCP | sshd | primary SSH listener |
| 54321 | TCP | nginx stream proxy | public PostgreSQL proxy to `100.64.0.2:5432` (pyrite `postgres` container, formerly `student-postgres`) |
| 2222 | TCP | Forgejo | git+ssh clones (container OpenSSH; `git.perdrizet.org:2222`) |
| 10000 | UDP | Jitsi JVB | WebRTC media (`meet.perdrizet.org`; no TURN fallback) |

## Active HTTPS domains on nginx

| Domain | Backend | State | Notes |
|--------|---------|-------|-------|
| perdrizet.org | static root `/opt/perdrizet.org` | active | static Astro site (HTTP 200); an older note said "redirects to logkeep" — wrong |
| www.perdrizet.org | redirect | active | 301 → apex `perdrizet.org` |
| logkeep.perdrizet.org | `127.0.0.1:8000` | active | LogKeep production |
| bench.perdrizet.org | `127.0.0.1:8010` | active | Bench production |
| bug-hunter.perdrizet.org | `127.0.0.1:8509` | active | Bug Hunter frontend |
| www.bug-hunter.perdrizet.org | `127.0.0.1:8509` | active | same frontend |
| feedback.perdrizet.org | `127.0.0.1:18080` | active | Feedback app |
| admin.perdrizet.org | `127.0.0.1:8600` | active | perdrizet-admin systemd service |
| promptlyapi.com | `127.0.0.1:8503` | active | model-gateway API; `/register` is rate-limited at nginx with a signup zone (`3r/m`, burst 2) |
| model.perdrizet.org | redirect | active | redirects to promptlyapi.com |
| grafana.perdrizet.org | `127.0.0.1:3000` | active | Grafana |
| headscale.perdrizet.org | `127.0.0.1:8090` | active | Headscale API |
| headplane.perdrizet.org | `127.0.0.1:3001` | active | Headscale UI |
| jupyter.perdrizet.org | `100.64.0.2:47302` | active | JupyterLab on pyrite |
| meet.perdrizet.org | `127.0.0.1:9080` | active | Jitsi Meet (JWT auth, members-only door); combined cert with git subdomain (SAN `git.perdrizet.org`) |
| git.perdrizet.org | `127.0.0.1:3300` | active | Forgejo web / Smart HTTP (LFS up to 1024m, buffering off) |
| nixx.perdrizet.org | `100.64.0.2:8000` | configured | pyrite service currently inactive |
| staging.perdrizet.org | `100.64.0.1:8003` | **down** | auth-gated logkeep staging; `logkeep-staging`/`logkeep-postgres-staging` containers exited since ~2026-10-30, nothing listens on `:8003` (auth returns 401, upstream would 502) |
| site-staging.perdrizet.org | static root | configured | staging static site endpoint |
| code.perdrizet.org | `100.64.0.2:47301` | configured | legacy OpenVSCode endpoint; not part of active pyrite service model |

## Tailnet-only HTTP listeners (nginx, `100.64.0.1`)

| Port | Target | Notes |
|------|--------|-------|
| 8003 | logkeep staging container | **down** — container exited (see domain table) |
| 8008 | static root `/opt/perdrizet.org-staging` | site-staging over tailnet |
| 8012 | `127.0.0.1:8011` (bench staging) | bench staging entry point |
| 8504–8507 | model-gateway API/adminer (prod+staging) | see [promptly-api](../../../services/promptly-api.md) for the exact matrix |

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
| monitoring-cadvisor | container metrics (host cgroups only — no per-container docker series) |
| monitoring-nginx-exporter | nginx metrics |
| monitoring-blackbox-exporter | HTTPS/TLS probes |
| bench-postgres-exporter / logkeep-postgres-exporter | app-owned exporters, loopback `:9188`/`:9187` |

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
- `model-gateway-api`, `model-gateway-db`, `model-gateway-adminer` (production)
- `model-gateway-api-staging`, `model-gateway-db-staging`,
  `model-gateway-adminer-staging` — full bind matrix in
  [services/promptly-api.md](../../../services/promptly-api.md)

### Jitsi Meet
- `jitsi-meet-web-1`, `jitsi-meet-prosody-1`, `jitsi-meet-jicofo-1`,
  `jitsi-meet-jvb-1` — upstream docker-jitsi-meet @ `stable-11509-1`, compose
  project at `/opt/jitsi-meet` (local git, no remote); config tree
  `/opt/jitsi-meet-config`; JWT MUC auth, no guests; public media udp/10000.
  Details: [services/jitsi-meet.md](../../../services/jitsi-meet.md)

### Forgejo
- `forgejo` — `codeberg.org/forgejo/forgejo:15` (live 15.0.12), compose at
  `/opt/forgejo` (github.com:gperdrizet/forgejo-setup); web `127.0.0.1:3300`
  + git+ssh public `2222`; PostgreSQL on pyrite (`forgejo_db` over
  `100.64.0.2:5432`, TLS+scram). Details:
  [services/forgejo.md](../../../services/forgejo.md)

### Other apps
- `feedback-*` containers
- `bug-hunter-*` containers (production + partial staging)

## Tailnet integration

- gatekeeper tailnet IP: `100.64.0.1`
- pyrite tailnet IP: `100.64.0.2`
- PostgreSQL public proxy path: `:54321` -> `100.64.0.2:5432`
  (backend: pyrite `postgres` container from `/opt/postgreSQL-server`; auth is
  postgres scram-sha-256 only, `limit_conn 5` per IP)
- Jupyter ingress path: `jupyter.perdrizet.org` -> `100.64.0.2:47302`

## Notes

- This file is intentionally current-state only.
- Migration notes and phase summaries are not tracked here.
