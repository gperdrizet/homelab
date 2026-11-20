# Web apps (gatekeeper)

Containerized application stacks on gatekeeper behind nginx. Compose files are
mirrored under
[machines/gatekeeper/](../machines/gatekeeper/docs/infrastructure-layout.md).

## LogKeep

| Item | Value |
|------|-------|
| Containers | `logkeep` (app), `logkeep-postgres`, `logkeep-postgres-exporter` |
| Bind | `127.0.0.1:8000` |
| Ingress | logkeep.perdrizet.org (perdrizet.org redirects here) |
| Notes | blue/green deploy symlink: `conf.d/logkeep.conf → logkeep-configs/blue.conf` |

## Bench (prod + staging)

| Item | Value |
|------|-------|
| Containers (prod) | `bench-web`, `bench-celery`, `bench-celery-beat`, `bench-postgres`, `bench-redis`, `bench-postgres-exporter` |
| Containers (staging) | `bench-*-staging` set |
| Bind | prod `127.0.0.1:8010`, staging `127.0.0.1:8011`; exporter `127.0.0.1:9188` (prod only) |
| Ingress | bench.perdrizet.org |
| DB | own `bench-postgres` / `bench-postgres-staging` containers on a docker bridge, **no published host ports**; DSNs from on-host `.env.production` / `.env.staging` (passwords never in the repo) |
| Deploy source | `/opt/bench/docker` on gatekeeper; compose mirrors in [compose/](../machines/gatekeeper/compose/bench-docker-compose.yml) (`bench-docker-compose.yml` dev, `.prod.yml`, `.staging.yml` — synced to live 2026-11-20) |

The VPS host port `127.0.0.1:5432` belongs to logkeep's postgres, not bench.

## Bug Hunter (prod + staging)

| Item | Value |
|------|-------|
| Containers | `bug-hunter-frontend`, `bug-hunter-backend`, `bug-hunter-db` (+ staging) |
| Bind | frontend `127.0.0.1:8509` |
| Ingress | bug-hunter.perdrizet.org, www.bug-hunter.perdrizet.org |

## Feedback

| Item | Value |
|------|-------|
| Containers | `feedback-app`, `feedback-worker`, `feedback-db` (image pinned by SHA) |
| Bind | `127.0.0.1:18080` |
| Ingress | feedback.perdrizet.org |

## perdrizet.org site

- `perdrizet-admin.service` (systemd, not docker) on `127.0.0.1:8600` →
  admin.perdrizet.org; apex redirects to logkeep.

## Staging endpoints

- `staging.perdrizet.org` — **logkeep staging slot** (`upstream
  logkeep_staging`, `conf.d/staging.conf`; nginx mirror shows `100.64.0.1:8003`
  path), not bench staging as an older note claimed
- `site-staging.perdrizet.org` — static staging root

TODO (stub-level): per-app repos, deploy pipelines, and backup schedules are
not yet documented here.
