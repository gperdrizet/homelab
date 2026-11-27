# the-educator

Home theater PC, mostly used for streaming. Also runs the Minecraft server.

## Hardware

**CPU:** Intel Xeon E3-1290 (8 threads)
**RAM:** 16 GB
**Storage:** 240 GB SSD (system), 2× 3.6 TB HDD (`ark`, `big_itch`)
**OS:** Ubuntu 22.04 LTS

## Network

- LAN: `10.1.10.204`
- **Not enrolled in the tailnet.**

## Services

| Service | Notes |
|---------|-------|
| `papermc.service` | Minecraft server — see [service page](../../services/minecraft.md) |
| Docker (`dockerd`) | data-root on the **local** RAID at `/home/siderealyear/ark/docker` — not on NFS |
| NFS client | `/home/siderealyear/arkk` ← `10.1.10.200:/mnt/arkk` (`ro,nofail`) — archive data window; repointed from dead `10.1.10.202` on 2026-11-20 |
| NFS server (`nfs-server`) | exports local `ark` + `big_itch` to `10.1.10.0/24` (`rw,no_root_squash,async`); no LAN clients currently mounting (2026-11-20) |

## TODO

- ~~Fix or remove the dead NFS fstab entry~~ — done 2026-11-20 (repointed to
  pyrite, `ro,nofail`).
- Enroll in tailnet (optional, for admin convenience).
- Document Minecraft port/world paths and backup expectations.
- Decide whether the outbound NFS exports (`ark`, `big_itch` — `rw` and
  `no_root_squash`) are still wanted; nothing currently mounts them.
