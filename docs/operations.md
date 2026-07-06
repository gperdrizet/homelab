# Operations

Task-oriented index into the operational runbooks for each machine and each
cross-cutting concern.

## Active incident: arkk RAID recovery

The arkk RAID5 array is degraded (1 of 5 disks failed) and mounted read-only
while a selective rescue backup runs to pyrite.

1. [2026 incident notes](machines/arkk/RAID_RECOVERY_2026.md) — current state,
   degraded-start procedure, resilver steps (deferred until backup verifies)
2. [Backup triage](machines/arkk/BACKUP_TRIAGE_2026.md) — keep/drop plan,
   thinning policy, run procedure
3. [General RAID recovery runbook](machines/arkk/RAID_RECOVERY.md)

## Machine runbooks

### gatekeeper (VPS ingress and public services)

- [Machine overview](machines/gatekeeper/README.md)
- [Service and port inventory](machines/gatekeeper/docs/services.md)
- [Infrastructure layout](machines/gatekeeper/docs/infrastructure-layout.md)
- [Backup operations](machines/gatekeeper/docs/backup-improvements.md)
- [Tailnet / Headscale setup](machines/gatekeeper/tailnet/README.md)

### pyrite (workstation, compute, and backup target host)

- [Machine overview](machines/pyrite/README.md)
- [Platform baseline](machines/pyrite/docs/platform-baseline.md)
- [Boot and startup](machines/pyrite/docs/boot-and-startup.md)
- [Remote access](machines/pyrite/docs/remote-access.md)
- [Troubleshooting](machines/pyrite/docs/troubleshooting.md)
- [Services on pyrite](machines/pyrite/services/README.md)

### arkk (NAS and storage)

- [Machine overview](machines/arkk/README.md) — see active incident above

## Cross-cutting

- [Backup strategy](backups/README.md)
- [Network documentation](network/README.md)
- [Secrets management](secrets/README.md)
- [Docker images](docker-images/README.md)

## History

- [Repo consolidation record (2026)](history/consolidation-2026.md) — migration
  of `admin/` and `vps-infrastructure/` into this repo
