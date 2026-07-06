# arkk

NAS and RAID storage server, physically located in the home office alongside pyrite.

**Status: RECOVERING** — array assembled **degraded (4/5 disks)**, rescue backup
to pyrite **complete and verified (1.4T)**. Ready to resilver the replacement
drive (ZGY9V4AT) — see [RAID_RECOVERY_2026.md](RAID_RECOVERY_2026.md#resilver-the-replacement-drive-ready-to-run).

---

## Hardware

**Form factor:** dish rack, top level  
**CPU:** AMD A8-3870 APU with Radeon HD Graphics  
**RAM:** 8 GB Corsair Vengeance 1333 MT/s (4 x 2GB)
**Storage (RAID array):**
- 5 × 4 TB Seagate IronWolf (MN: ST4000VN008-2DR1) via mdadm (RAID5, `/dev/md0`, xfs)
- Active members: ZGY8RDRE, ZGY8S00W, ZGY8RLDM, ZGY8NY0Q
- Failed: ZGY8RFGN (slot 3)
- Replacement: ZGY9V4AT (installed; currently a spare — **not** yet resilvered)
- **Current state:** degraded `[UUU_U]` (4/5), assembled read-only for rescue backup

**OS:** Ubuntu Server 20.04.6 LTS  
**Network:**
- LAN gigabit Ethernet (`10.1.10.201`)
- Direct bonded dual-gigabit link to pyrite: `bond0` = `192.168.2.1` (arkk) ↔ `192.168.2.2` (pyrite); ~200 MB/s iperf
- NFS: `/mnt/arkk` exported read-only to `192.168.2.2` during recovery
- TODO: Tailscale client when operational

---

## Role

- Primary backup target for gatekeeper databases and application data
- Primary backup target for pyrite documents, photos, and project files
- NFS server: exposes storage to pyrite over the direct bonded link
- Offsite backup staging point (future: restic → cloud)

---

## Recovery Status

- [x] Replacement drive installed (ZGY9V4AT, present as spare `sda1`)
- [x] Array assembled degraded (4/5) and mounted read-only
- [x] NFS export re-established to pyrite (read-only, bonded link)
- [x] Selective rescue backup to pyrite complete and verified (1.4T to `/mnt/glass`)
- [ ] Spare re-added; RAID resilvering complete
- [ ] Array remounted read-write; NFS exports restored to normal
- [ ] Backup jobs re-pointed to arkk
- [ ] Tailscale client reconnected

---

## Network (current)

| Interface | Address | Notes |
|-----------|---------|-------|
| LAN | 10.1.10.201 | Router-connected, SSH access |
| bond0 | 192.168.2.1/24 | Direct bonded link to pyrite (192.168.2.2) |
| Tailscale | TBD | Reconnect after recovery |

---

## NFS Exports

During recovery: `/mnt/arkk` exported **read-only** to `192.168.2.2` (pyrite)
over the bonded link. Normal (post-recovery) exports TBD when the array is
remounted read-write.

---

## Recovery Tools

### Rescue backup scripts

The 2026 rescue backup runs from pyrite against the NFS mount. Scripts and
selection lists live in the `scripts/` directory alongside this page:

- `run_backup.sh` — orchestrates both passes with logging and preflight checks
- `rsync_selected_from_arkk.sh` + `targets.txt` / `excludes.txt` — bulk selective copy
- `thin_checkpoints_from_arkk.sh` + `checkpoint_dirs.txt` — thinned GAN checkpoint ladder

```bash
cd ~/homelab/docs/machines/arkk/scripts
./run_backup.sh -s /mnt/arkk -d /mnt/glass/arkk -n   # dry run
./run_backup.sh -s /mnt/arkk -d /mnt/glass/arkk      # real run
```

See [BACKUP_TRIAGE_2026.md](BACKUP_TRIAGE_2026.md) for the full keep/drop plan
and run procedure.

---

## See also

- [backups/README.md](../../backups/README.md): restic backup strategy
- [network/lan.md](../../network/lan.md): bonded link configuration
