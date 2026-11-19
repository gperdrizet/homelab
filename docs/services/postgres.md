# PostgreSQL

Multi-tenant PostgreSQL on pyrite, tailnet-scoped, with one public path via
gatekeeper. **Repo:**
[gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server).

## Deployment (pyrite)

| Container | Image | Bind |
|-----------|-------|------|
| student-postgres | `pgvector/pgvector:pg16` | `100.64.0.2:5432` (tailnet only) |
| pgadmin | `dpage/pgadmin4:8.14` | `100.64.0.2:8088` |
| postgres-exporter | `prometheuscommunity/postgres-exporter` | `100.64.0.2:9187` |

## Public access

gatekeeper nginx **stream** proxy: public `:54321` → `100.64.0.2:5432`.

## Consumers

- Promptly model-gateway uses its own local DB on gatekeeper
  (`model-gateway-db`), **not** this server.
- Bench, bug-hunter, logkeep, feedback each run private postgres containers on
  gatekeeper (see [web apps](web-apps.md)).

This server is for student/multi-tenant workloads and direct tailnet clients.

## Backups

TODO: confirm current dump schedule for `student-postgres` (old backup docs
target the decommissioned arkk).
