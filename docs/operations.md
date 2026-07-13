# Operations

Task-oriented index into the operational runbooks for each machine and each
cross-cutting concern.

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

- [Machine overview](machines/arkk/README.md)
- [RAID recovery runbook](machines/arkk/RAID_RECOVERY.md)

## Cross-cutting

- [Backup strategy](backups/README.md)
- [Monitoring inventory](operations/monitoring-inventory.md)
- [Network documentation](network/README.md)
- [Secrets management](secrets/README.md)
- [Docker images](docker-images/README.md)
