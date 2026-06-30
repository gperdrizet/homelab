# RAID Array Recovery - arkk NAS

This runbook combines the original recovery guide with the additional degraded-start
steps discovered during recovery when the array appeared as `inactive` and members
were marked as spares `(S)`.

**Array**: /dev/md0 (RAID5, 5 disks, ~15TB usable)

---

## Current Situation Template

Use this section to record real-time state during incidents.

- Array status from `cat /proc/mdstat`
- Failed disk device and serial number
- Replacement disk device and serial number
- Any observed I/O errors from `dmesg`

---

## Pre-Recovery Checklist

- [ ] Backup critical data if possible
- [ ] Cold spare drive ready (same size or larger)
- [ ] Record serial number of the replacement drive
- [ ] Confirm maintenance window and power-off plan
- [ ] Keep commands in a shell history log during recovery

---

## Device Mapping Checklist (Fill Before Destructive Steps)

Do this once per recovery session and reuse the same values through Steps 5-9.

1. Capture disk inventory by serial:

```bash
lsblk -o NAME,SERIAL,SIZE,MODEL,TYPE
sudo mdadm --detail /dev/md0
```

2. Fill this table:

| Purpose | Example | Your value | Verified by serial? |
|---|---|---|---|
| New replacement disk (whole disk) | /dev/sdf |  | [ ] |
| New replacement partition | /dev/sdf1 |  | [ ] |
| Known-good member for partition clone | /dev/sdb |  | [ ] |
| Failed/removed slot number | 3 |  | [ ] |

3. Export variables to reduce typo risk:

```bash
export NEW_DISK=/dev/sdX
export NEW_PART=${NEW_DISK}1
export GOOD_DISK=/dev/sdY
```

4. Sanity check before running write operations:

```bash
echo "NEW_DISK=$NEW_DISK NEW_PART=$NEW_PART GOOD_DISK=$GOOD_DISK"
lsblk -o NAME,SERIAL,SIZE,MODEL "$NEW_DISK" "$GOOD_DISK"
```

Only proceed when serial numbers match your worksheet.

---

## Recovery Steps

### Step 1: Verify Current State Before Shutdown

```bash
ssh arkk
cat /proc/mdstat
sudo mdadm --detail /dev/md0
lsblk -o NAME,SERIAL,SIZE,MODEL
sudo smartctl -i "$NEW_DISK" 2>/dev/null | grep "Serial Number" || true
```

Confirm data is currently accessible if possible:

```bash
ls -la /mnt/arkk
```

### Step 2: Unmount and Stop Array

```bash
sudo umount /mnt/arkk || true
sudo mdadm --stop /dev/md0 || true
cat /proc/mdstat
```

### Step 3: Power Down

```bash
sudo shutdown -h now
```

### Step 4: Physical Disk Swap

1. Disconnect power.
2. Locate failed disk by serial number, not SATA port.
3. Remove failed disk and install replacement.
4. Reconnect and boot.

### Step 5: Verify New Disk Detection

```bash
ssh arkk
lsblk -o NAME,SERIAL,SIZE,MODEL
sudo smartctl -H "$NEW_DISK"
```

If the replacement drive was previously used, old RAID metadata can exist. That is
handled below.

### Step 6: Start Array (Degraded) - Updated Procedure

If `/proc/mdstat` shows `md0 : inactive ... (S)`, metadata is present but the array
is not running yet.

#### Step 6a: Stop inactive assembly first

```bash
sudo mdadm --stop /dev/md0
```

#### Step 6b: Assemble degraded, read-only, and force-run

Use all candidate RAID member partitions for this host, excluding devices with no
md superblock.

```bash
sudo mdadm --assemble --readonly --force --run /dev/md0 /dev/sd[a-f]1
```

Notes:
- `--force` may be required when one member has stale `Events`.
- If a replacement disk is currently marked `spare`, degraded read-only start can
	still succeed for recovery.

#### Step 6c: Validate array is truly active

```bash
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

Expected degraded recovery shape:
- `md0 : active (read-only) raid5`
- `[5/4] [UUU_U]` or equivalent

#### Step 6d: Mount read-only for data extraction

```bash
sudo mkdir -p /mnt/arkk
sudo mount -o ro /dev/md0 /mnt/arkk
```

If mount fails, verify if filesystem is on a partitioned md node:

```bash
lsblk -f
sudo blkid /dev/md0 /dev/md0p1
```

Then mount `/dev/md0p1` if required.

#### Step 6e: If assembly still fails

Check metadata consistency and event counters:

```bash
sudo mdadm --examine /dev/sd[a-z]1 | egrep -i "Array UUID|Raid Level|Raid Devices|Device Role|Events|State"
```

Check kernel logs for read/I/O failures:

```bash
dmesg -T | egrep -i "md0|I/O error|raid|sd[a-f]" | tail -n 100
```

Common causes:
- Omitted required member in assemble command
- Stale member rejected without `--force`
- True disk I/O error on one of the remaining members

### Step 7: Clean Replacement Drive Metadata (if needed)

```bash
cat /proc/mdstat
lsblk "$NEW_DISK"
sudo mdadm --examine "$NEW_PART" || true
sudo mdadm --zero-superblock "$NEW_PART" || true
sudo wipefs -a "$NEW_DISK"
```

### Step 8: Partition Replacement Disk

Copy partition layout from a known-good member disk.

```bash
sudo sfdisk -d "$GOOD_DISK" | sudo sfdisk "$NEW_DISK"
lsblk "$NEW_DISK"
```

### Step 9: Add New Disk to Array

```bash
sudo mdadm --manage /dev/md0 --add "$NEW_PART"
cat /proc/mdstat
```

### Step 10: Monitor Rebuild

```bash
watch -n 5 cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

### Step 11: Verify Completion

```bash
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

Target state:
- `[5/5] [UUUUU]`
- `State : clean`

### Step 12: Persist Assembly at Boot

```bash
sudo cp /etc/mdadm/mdadm.conf /etc/mdadm/mdadm.conf.backup
sudo mdadm --detail --scan | sudo tee /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

---

## Data Recovery Workflow (Recommended Before Rebuild)

When the array is degraded, prioritize extraction first.

1. Keep array read-only.
2. Mount read-only on arkk.
3. Pull data from backup host using rsync over SSH.
4. Repeat rsync to catch partials.

Selective-copy helper script in this repo:
- `machines/arkk/scripts/rsync_selected_from_arkk.sh`

---

## Troubleshooting Quick Reference

### New disk not detected

```bash
echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan
dmesg -T | tail -n 100
```

### mdadm add fails

```bash
sudo mdadm --examine "$NEW_PART"
sudo mdadm --zero-superblock "$NEW_PART"
sudo mdadm --manage /dev/md0 --add "$NEW_PART"
```

### Array will not start

```bash
sudo mdadm --assemble --readonly --force --run /dev/md0 /dev/sd[a-f]1
sudo mdadm --examine /dev/sd[a-f]1 | grep -i Events
```

---

## Reference

- mdadm manual: `man mdadm`
- SMART manual: `man smartctl`
