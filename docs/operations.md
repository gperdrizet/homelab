# Operations

Task-oriented index into the operational docs. Audited 2026-11-18.

## Start with the service

Most day-2 questions are about a service, not a machine:
[services inventory](services/README.md).

## Machine runbooks

### gatekeeper (VPS ingress and public services)

- [Machine overview](machines/gatekeeper/README.md)
- [Infrastructure layout](machines/gatekeeper/docs/infrastructure-layout.md)
- [Backup operations](machines/gatekeeper/docs/backup-improvements.md)
- [Incidents and resilience](machines/gatekeeper/docs/incidents.md)
- [Tailnet / Headscale setup](machines/gatekeeper/tailnet/README.md)
- [Nginx configuration model](machines/gatekeeper/configs/nginx/README.md)

### pyrite (compute, inference, storage)

- [Machine overview](machines/pyrite/README.md)
- [Platform baseline](machines/pyrite/docs/platform-baseline.md)
- [Boot and startup](machines/pyrite/docs/boot-and-startup.md)
- [Remote access](machines/pyrite/docs/remote-access.md)
- [Troubleshooting](machines/pyrite/docs/troubleshooting.md)
- [bcache guide](machines/pyrite/guides/bcache.md)

### ethics-gradient / the-educator / hugo

- [ethics-gradient](machines/ethics-gradient/README.md) ·
  [the-educator](machines/the-educator/README.md) ·
  [hugo](machines/hugo/README.md)

## Cross-cutting

- [Backup strategy](backups/README.md)
- [Monitoring](services/monitoring.md) (+ [2026-09 inventory snapshot](operations/monitoring-inventory.md))
- [Network](network/README.md) — [LAN](network/lan.md) · [tailnet](network/tailnet.md) · [NFS](network/nfs.md)
- [Secrets management](secrets/README.md)
- [Docker images](docker-images/README.md)

## Known open items (from the 2026-11 audit)

- the-educator fstab still mounts dead arkk (no `nofail`) — see
  [NFS fix list](network/nfs.md#fix-list).
- pyrite root disk ~93 %; ethics-gradient root ~91 %.
- Stale `laptop` node in Headscale.
- Backup destinations for restic/pg dumps need re-confirmation now that the
  RAID lives on pyrite (a backup target that shares a host with its primary
  data is not a backup).
