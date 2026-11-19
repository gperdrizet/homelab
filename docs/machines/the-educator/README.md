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
| NFS client | fstab entry still points at decommissioned arkk (`10.1.10.202`) — **broken**, no `nofail`; see [network/nfs.md](../../network/nfs.md#fix-list) |

## TODO

- Fix or remove the dead NFS fstab entry.
- Enroll in tailnet (optional, for admin convenience).
- Document Minecraft port/world paths and backup expectations.
