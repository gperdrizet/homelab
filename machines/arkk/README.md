# arkk

NAS and RAID storage server, physically located in the home office alongside pyrite.

**Status: RECOVERING**: drive replacement in progress, resilvering and restore needed.

---

## Hardware

<!-- TODO: fill in actual specs -->
**Form factor:** <!-- e.g. Tower / rackmount -->  
**CPU:** <!-- e.g. Intel Core i3 -->  
**RAM:** <!-- e.g. 16 GB ECC DDR4 -->  
**Storage (RAID array):**
- <!-- e.g. 4 × 8 TB WD Red, RAID 5/6 via mdadm or ZFS -->
- <!-- Drive that failed: -->
- <!-- Replacement drive: -->
- **Current state:** Resilvering / restoring after drive replacement

**OS:** <!-- e.g. Ubuntu Server / TrueNAS -->  
**Network:**
- LAN (gigabit Ethernet to router)
- Direct bonded link to pyrite (high-speed NFS)
- Tailscale client (100.64.0.<!-- TODO -->) when operational

---

## Role

- Primary backup target for gatekeeper databases and application data
- Primary backup target for pyrite documents, photos, and project files
- NFS server: exposes storage to pyrite over the direct bonded link
- Offsite backup staging point (future: restic → cloud)

---

## Recovery Status

- [ ] Replacement drive installed
- [ ] RAID resilvering complete
- [ ] Data restore complete
- [ ] NFS shares re-exported to pyrite
- [ ] Backup jobs re-pointed to arkk
- [ ] Tailscale client reconnected

---

## Network (when operational)

| Interface | Address | Notes |
|-----------|---------|-------|
| eth0 (LAN) | DHCP / static | Router-connected |
| bond0 | <!-- e.g. 192.168.10.2 --> | Direct bonded link to pyrite |
| Tailscale | 100.64.0.<!-- TODO --> | Tailnet access |

---

## NFS Exports

<!-- TODO: document NFS share paths once restored -->

---

## See also

- [backups/README.md](../../backups/README.md): restic backup strategy
- [network/lan.md](../../network/lan.md): bonded link configuration
