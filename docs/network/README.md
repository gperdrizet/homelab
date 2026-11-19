# Network

How the homelab machines connect to each other and to the internet.
Audited 2026-11-18.

## Topology

```
Internet
    │
    ├── 74.208.107.78 ── [gatekeeper]  100.64.0.1 (Headscale control + exit node)
    │
    └── Home LAN 10.1.10.0/24
            ├── [pyrite]         10.1.10.200   100.64.0.2   NFS server (/mnt/arkk)
            ├── [ethics-gradient] (dhcp)       100.64.0.5
            ├── [the-educator]   10.1.10.204   (no tailnet)
            └── [hugo]           10.1.10.143   (no tailnet)
```

Mobile/roaming: `voxxel` (Android, 100.64.0.6) joins the tailnet from wherever;
`laptop` (100.64.0.3) is stale (offline months).

## Layers

- **LAN (10.1.10.0/24)** — home router; static assignments for servers. See
  [lan.md](lan.md).
- **Tailnet (100.64.0.0/24)** — Headscale mesh; canonical path for service
  traffic between machines. See [tailnet.md](tailnet.md).
- **NFS** — pyrite exports the 15 TB array to LAN clients. See [nfs.md](nfs.md).

## Decommissioned

- `arkk` (old NAS, 10.1.10.201/.202) and its 192.168.2.0/24 direct link to
  pyrite are **gone**. The RAID5 was moved into pyrite. Historical docs:
  [archive/arkk](../archive/arkk/README.md).
