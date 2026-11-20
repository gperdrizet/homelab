# Backups

Backup strategy for all homelab machines and data.

---

## Tool: restic

[restic](https://restic.net/) handles all backups: deduplication, encryption at rest,
multiple backend support. One tool, consistent workflow across all sources.

---

## Backup targets

**Primary target:** the 15 TB RAID array (formerly `arkk`, now a **local array
on pyrite** at `/mnt/arkk`)  
**Offsite target:** TBD; research in progress (Backblaze B2, Wasabi S3, or similar)

!!! warning "Backup topology changed"
    With the array now local to pyrite, backups of **pyrite host data** no
    longer have an independent target — a disk/fire event on pyrite takes both.
    Offsite (restic → B2/Wasabi) is now the priority gap. Backups of
    gatekeeper databases over the network still work as documented.

## What is actually running (verified 2026-11-19)

| Job | Where | Detail |
|-----|-------|--------|
| `0 2 * * * /srv/backups/backup-databases.sh` | gatekeeper cron | `docker exec … pg_dump | gzip` for **logkeep + logkeep_staging** DBs; ~313 daily dumps retained on gatekeeper itself, no offsite copy, bench/feedback/bug-hunter DBs **not** covered |
| `0 3 * * * /srv/infra/scripts/backup-healthcheck.sh` | gatekeeper cron | checks the above; log at `/var/log/backup-healthcheck.log` |
| `0 3 * * * /opt/postgreSQL-server/scripts/backup.sh` | pyrite cron | `pg_dumpall \| gzip` of the multi-tenant postgres DB (30-day retention) → `/mnt/arkk/postgreSQL-server/backups/`; log at `/mnt/arkk/postgreSQL-server/backups/backup.log`. **No restic and no other cron backups on pyrite** — host data + 15 TB array otherwise have zero backups |
| — | ethics-gradient / the-educator | nothing; Minecraft world unprotected |

---

## Sources

### gatekeeper

| Data | Method | Frequency |
|------|--------|-----------|
| PostgreSQL databases (logkeep, bench, etc.) | `pg_dump` → gzip → rsync to pyrite | Daily 2 AM (existing cron) |
| `/opt/` application data | restic | TBD |
| `/srv/infra/data/` (Prometheus, Grafana, Loki) | restic | TBD |

Existing backup script: `/srv/backups/backup-databases.sh` (7-day retention, synced to pyrite)

### pyrite

| Data | Method | Frequency |
|------|--------|-----------|
| `~/Documents`, `~/Photos` | restic → arkk | TBD |
| Project repos (`~/code/`) | restic → arkk | TBD |
| llama.cpp model weights | restic → arkk (large, infrequent) | TBD |

---

## restic quickstart (reference)

```bash
# Initialize a new repo on arkk (run once)
restic -r /mnt/arkk/backups/pyrite init

# Run a backup
restic -r /mnt/arkk/backups/pyrite backup ~/Documents ~/Photos

# List snapshots
restic -r /mnt/arkk/backups/pyrite snapshots

# Restore latest snapshot
restic -r /mnt/arkk/backups/pyrite restore latest --target /tmp/restore
```

Passwords for restic repos are stored in Vaultwarden. See [secrets/README.md](../secrets/README.md).

---

## Scripts

<!-- TODO: add restic wrapper scripts here once arkk is restored -->
