# arkk

NAS and RAID storage server, physically located in the home office alongside pyrite.

**Status: RECOVERING**: drive replacement in progress, resilvering and restore needed.

---

## Hardware

**Form factor:** dish rack, top level  
**CPU:** AMD A8-3870 APU with Radeon HD Graphics  
**RAM:** 8 GB Corsair Vengeance 1333 MT/s (4 x 2GB)
**Storage (RAID array):**
- 5 × 4 TB Seagate IronWolf (MN: ST4000VN008-2DR1) via mdadm
- ZGY8RDRE, ZGY8S00W, ZGY8RLDM, ZGY8NY0Q
- Failed: ZGY8RFGN
- Replacement: ZGY9V4AT
- **Current state:** Resilvering / restoring after drive replacement

**OS:** Ubuntu Server 20.04.6 LTS  
**Network:**
- LAN (gigabit Ethernet to router)
- Direct bonded dual gigabit link to pyrite (high-speed NFS)
- TODO: Tailscale client (100.64.0.<!-- TODO -->) when operational

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

## Recovery Tools

### Selective copy script (rsync over SSH)

Use this from the backup machine when you only want specific directories from `/mnt/arkk`.

Script: [scripts/rsync_selected_from_arkk.sh](scripts/rsync_selected_from_arkk.sh)  
Example targets list: [scripts/targets.example.txt](scripts/targets.example.txt)
Example excludes list: [scripts/excludes.example.txt](scripts/excludes.example.txt)

Example:

```bash
./machines/arkk/scripts/rsync_selected_from_arkk.sh \
	-f ./machines/arkk/scripts/targets.example.txt \
	-x ./machines/arkk/scripts/excludes.example.txt \
	-d /srv/backups/arkk \
	-s siderealyear@arkk:/mnt/arkk
```

Exclude patterns let you keep a parent directory while skipping noisy subdirectories
like `logs/` or `data/tmp/`.

### RAID degraded-start runbook

See [RAID_RECOVERY.md](RAID_RECOVERY.md), especially:
- Step 6a: stop inactive md device
- Step 6b: assemble with `--readonly --force --run`
- Step 6d: mount read-only for data extraction

---

## See also

- [backups/README.md](../../backups/README.md): restic backup strategy
- [network/lan.md](../../network/lan.md): bonded link configuration
