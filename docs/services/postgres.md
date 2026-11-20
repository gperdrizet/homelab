# PostgreSQL

Multi-tenant PostgreSQL on pyrite, tailnet-scoped, with one public path via
gatekeeper. **Repo:**
[gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server).

## Deployment (pyrite)

Deployed from the repo at **`/opt/postgreSQL-server`** on pyrite
(`docker-compose.yml`, host `.env` from `.env.template`).

| Container | Image | Bind |
|-----------|-------|------|
| postgres | `pgvector/pgvector:pg16` | `100.64.0.2:5432` (tailnet only) |
| pgadmin | `dpage/pgadmin4:9.19` | `100.64.0.2:8088` (tailnet only) |
| postgres-exporter | `prometheuscommunity/postgres-exporter` | `100.64.0.2:9187` |

The container was named `student-postgres` until the 2026-11-20 deployment;
the name is historical, the role is the same.

## Public access

gatekeeper nginx **stream** proxy: public `:54321` → `100.64.0.2:5432`.

## Consumers

- Promptly model-gateway uses its own local DB on gatekeeper
  (`model-gateway-db`), **not** this server.
- Bench, bug-hunter, logkeep, feedback each run private postgres containers on
  gatekeeper (see [web apps](web-apps.md)).

This server is the main multi-tenant database: per-student databases and login
roles (55 student roles as of 2026-11-20), reachable from the internet through
the public proxy below, guarded by scram-sha-256 passwords. `pg_hba.conf` has
an intentional `0.0.0.0/0` scram catch-all so proxied client addresses can
authenticate; local socket access is `trust`.

## Monitoring

`postgres-exporter` is scraped by the central Prometheus on gatekeeper (job
`pyrite-postgres-exporter`); dashboard `postgres-main-overview` on the central
Grafana. The project's local Prometheus/Grafana were removed 2026-11-19.

## Backups

Daily at 03:00 via pyrite cron: `scripts/backup.sh` in the deployment repo
(`pg_dumpall -U admin | gzip`, 30-day retention) →
`/mnt/arkk/postgreSQL-server/backups/`; log appended to
`/mnt/arkk/postgreSQL-server/backups/backup.log`. Verified 2026-11-20:
`full_backup_2026-11-20_00-30-11.sql.gz` present.
