# Local network: LAN layout

All home machines connect through the household router on `10.1.10.0/24`. No
services are exposed directly from the LAN; public endpoints run on gatekeeper.

| Device | Interface | IP | Notes |
|--------|-----------|----|-------|
| `pyrite` | lan-ssh | 10.1.10.200 | static; SSH + NFS server |
| `ethics-gradient` | (dhcp) | — | daily desktop; tailnet is the stable path (100.64.0.5) |
| `the-educator` | lan | 10.1.10.204 | HTPC / Minecraft |
| `hugo` | wifi/lan | 10.1.10.143 | RPi 0 W |
| `voxxel` | wifi | dhcp | Android phone |
| `gatekeeper` | — | 74.208.107.78 | public VPS, not on LAN |

## Historical

- `arkk` used `10.1.10.201` (lan-ssh) and `10.1.10.202` (bonded lan-data), plus
  a `192.168.2.0/24` direct link to pyrite (`arkk-link`/`pyrite-link`). All
  removed with the machine; see [archive/arkk](../archive/arkk/README.md).

## TODO

- Confirm DHCP reservations vs statics for the-educator and hugo.
- ethics-gradient: pin an address or document "use tailnet DNS".
- Netplan details for pyrite's interfaces still accurate? (verify against
  `/etc/netplan/`)
