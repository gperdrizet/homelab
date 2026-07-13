# arkk

NAS and RAID storage server, physically located in the home office alongside pyrite.

**Status: ACTIVE** — mdadm array is assembled and healthy (`[UUUUU]`), mounted
at `/mnt/arkk`, and exported over NFS.

---

## Hardware

**Form factor:** dish rack, top level  
**CPU:** AMD A8-3870 APU with Radeon HD Graphics  
**RAM:** 8 GB Corsair Vengeance 1333 MT/s (4 x 2GB)
**Storage (RAID array):**
- 5 × 4 TB Seagate IronWolf (MN: ST4000VN008-2DR1) via mdadm (RAID5, `/dev/md0`, xfs)
- **Current state:** healthy `[UUUUU]` (5/5), mounted read-write at `/mnt/arkk`

**OS:** Ubuntu Server 20.04.6 LTS  
**Network:**
- LAN gigabit Ethernet (`10.1.10.201`)
- Dedicated link to pyrite: `pyrite-link` = `192.168.2.1` (arkk) ↔ `192.168.2.2` (pyrite)
- NFS: `/mnt/arkk` exported read-write to pyrite and LAN clients
- Tailscale: not active on arkk

---

## Role

- Primary backup target for gatekeeper databases and application data
- Primary backup target for pyrite documents, photos, and project files
- NFS server: exposes storage to pyrite over the dedicated direct link
- Secondary NFS path available to LAN hosts on `10.1.10.0/24`

---

## Network (current)

| Interface | Address | Notes |
|-----------|---------|-------|
| LAN | 10.1.10.201 | Router-connected, SSH access |
| pyrite-link | 192.168.2.1/24 | Direct link to pyrite (192.168.2.2) |
| lan-data | 10.1.10.202 | Secondary LAN interface |

---

## NFS Exports

Current exports:
- `/mnt/arkk` -> `192.168.2.2` (pyrite, read-write)
- `/mnt/arkk` -> `10.1.10.0/24` (LAN hosts, read-write)

---

## Scripts

Utility scripts and selection lists used for backup operations are in
`scripts/`. Keep these aligned with current mount paths and target hosts.

---

## See also

- [backups/README.md](../../backups/README.md): restic backup strategy
- [network/lan.md](../../network/lan.md): LAN and direct-link configuration
