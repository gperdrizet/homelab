# Machines

High-level inventory of homelab machines and their roles. Per-service detail
lives in the [service inventory](services/README.md).

| Machine | Hardware | OS | Tailnet IP | LAN IP | Role |
|---------|----------|----|-----------|--------|------|
| gatekeeper | IONOS VPS, 4 vCPU EPYC, 8 GB, 240 GB | Ubuntu 22.04 | 100.64.0.1 | — (public 74.208.107.78) | Public ingress, apps, monitoring, Headscale, exit node |
| pyrite | Xeon E5-2697 v2, 24c, 251 GB, 2× Tesla P100 16 GB | Ubuntu 24.04 | 100.64.0.2 | 10.1.10.200 | ML/AI workhorse: inference + LiteLLM router, PostgreSQL, 15 TB RAID5, `fast_scratch` bcache |
| ethics-gradient | i5-12600KF, 16 GB, GTX 1070 8 GB | Ubuntu 26.04 | 100.64.0.5 | — | Daily desktop; embedding + utility inference container |
| the-educator | Xeon E3-1290, 8c, 16 GB, 2× 3.6 TB | Ubuntu 22.04 | not enrolled | 10.1.10.204 | HTPC / streaming; Minecraft server |
| hugo | Raspberry Pi 0 W, 512 MB | Raspbian 11 | not enrolled | 10.1.10.143 | Spare |

## Notes

- Public traffic terminates on gatekeeper only.
- pyrite services are consumed over the tailnet (`100.64.0.2`).
- The 15 TB RAID5 formerly on `arkk` is now a local mdadm array in pyrite
  (`/dev/md127` → `/mnt/arkk`) and is exported over NFS from pyrite.
- `laptop` (offline) and `voxxel` (Android phone) are tailnet clients with no
  machine pages.
