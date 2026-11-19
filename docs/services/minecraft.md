# Minecraft (the-educator)

PaperMC server on the-educator. Verified 2026-11-19.

| Item | Value |
|------|-------|
| Service | `papermc.service` (systemd) — running |
| User / workdir | `siderealyear` / `/opt/minecraft` |
| Launch | `/usr/local/bin/start_papermc` |
| Port | `25565` on `0.0.0.0` (java) |
| Access | LAN only; not exposed publicly, host not on tailnet |

## TODO

- World/backup: `/opt/minecraft` is local to the-educator; nothing backs it up.
- Consider tailnet enrollment + exposing backup of the world to the array.
