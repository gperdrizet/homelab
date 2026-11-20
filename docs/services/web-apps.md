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

Verified against live containers and nginx configs **2026-11-20**.

## Bench (prod + staging)

| Item | Value |
|------|-------|
| Containers (prod) | `bench-web`, `bench-celery`, `bench-celery-beat`, `bench-postgres`, `bench-redis`, `bench-postgres-exporter` |
| Containers (staging) | `bench-*-staging` set |
| Bind | prod `127.0.0.1:8010`, staging `127.0.0.1:8011`; exporter `127.0.0.1:9188` (prod only) |
| Ingress | bench.perdrizet.org; bench **staging** is tailnet-only via nginx `100.64.0.1:8012` → `127.0.0.1:8011` (`conf.d/bench-staging.conf`) — it is *not* `staging.perdrizet.org` |
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

- Apex `perdrizet.org` is a **static site** — nginx `root /opt/perdrizet.org`
  (Astro build, HTTP 200 verified 2026-11-20). `www` 301-redirects to apex.
  It does **not** redirect to logkeep (older docs claimed that).
- `admin.perdrizet.org` → `perdrizet-admin.service` (systemd, not docker) on
  `127.0.0.1:8600` (live: HTTP 405 on HEAD). Static staging site mirror of the
  apex lives at `site-staging.perdrizet.org` (root `/opt/perdrizet.org-staging`,
  also tailnet `100.64.0.1:8008`).

## Staging endpoints

- `staging.perdrizet.org` — **logkeep staging slot** (`upstream
  logkeep_staging` = `100.64.0.1:8003`, `conf.d/staging.conf`), *not* bench
  staging as an older note claimed. As of **2026-11-20** the upstream is down:
  `logkeep-staging` and `logkeep-postgres-staging` have been exited since
  ~2026-10-30, nothing listens on `:8003`; the vhost's auth gate answers 401
  before the (would-be 502) proxy.
- `site-staging.perdrizet.org` — static staging root (plus tailnet listener
  `100.64.0.1:8008`)

TODO (stub-level): per-app repos, deploy pipelines, and backup schedules are
not yet documented here.
