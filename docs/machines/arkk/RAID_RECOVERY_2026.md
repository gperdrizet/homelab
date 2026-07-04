# RAID Array Recovery - arkk NAS

**Date**: February 11, 2026  
**Array**: /dev/md0 (RAID5, 5 disks, ~15TB usable)  
**Status**: Degraded but operational (4/5 disks active)

---

## 2026 backup triage status (pre-resilver)

Current rescue workflow for this incident:

- Backup target host: pyrite
- Temporary rescue capacity: 2.7T RAID0 on pyrite
- Priority: copy selected high-value datasets before rebuilding parity

Active working notes and copy lists are maintained in:

- [BACKUP_TRIAGE_2026.md](BACKUP_TRIAGE_2026.md)

Use selective rsync workflow from [RAID_RECOVERY.md](RAID_RECOVERY.md) and
`docs/machines/arkk/scripts/rsync_selected_from_arkk.sh` to prioritize transfer
order and rerun copy passes for partials.

---

## Current Situation

The array is running in **degraded mode** with 4 working disks. One disk (sdd) has failed with I/O errors.

### Working Disks
| Device | Serial Number | Size | Model | Status |
|--------|---------------|------|-------|--------|
| /dev/sda1 | ZGY8S00W | 4TB | ST4000VN008-2DR1 (Seagate IronWolf) | Active in array |
| /dev/sdc1 | ZGY8NY0Q | 4TB | ST4000VN008-2DR1 (Seagate IronWolf) | Active in array |
| /dev/sde1 | ZGY8RLDM | 4TB | ST4000VN008-2DR1 (Seagate IronWolf) | Active in array |
| /dev/sdf1 | ZGY8RDRE | 4TB | ST4000VN008-2DR1 (Seagate IronWolf) | Active in array |

### Failed Disk
| Device | Serial Number | Size | Model | Status |
|--------|---------------|------|-------|--------|
| /dev/sdd | **ZGY8RFGN** | 4TB | ST4000VN008-2DR1 (Seagate IronWolf) | **FAILED** - I/O errors |

> **Recorded**: February 23, 2026 via `lsblk -o NAME,SERIAL,SIZE,MODEL`

### Array Status (as of recovery)
```
md0 : active raid5 sdb1[0] sda1[5] sdc1[2] sde1[1]
      15627540480 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUU_U]
```

- `[UUU_U]` = 4 active, slot 3 missing
- State: `clean, degraded`
- Data is intact and accessible

---

## Pre-Recovery Checklist

- [ ] **Backup critical data** if possible (degraded RAID5 has no redundancy)
- [ ] Cold spare drive ready (4TB, same size as others)
- [ ] **Note the serial number** of the new spare drive (on label or run `smartctl -i`)
- [ ] System powered off
- [ ] Coffee brewed

---

## Recovery Steps

### Step 1: Verify Current State (Before Shutdown)

SSH into arkk and confirm the array is still healthy:

```bash
ssh arkk

# Check array status
cat /proc/mdstat

# Should show: [UUU_U] and "clean, degraded"
sudo mdadm --detail /dev/md0

# IMPORTANT: Record serial numbers of ALL disks (update tables above)
# The failed disk's serial is how you'll identify it physically
lsblk -o NAME,SERIAL,SIZE,MODEL

# If the failed disk doesn't respond to lsblk, try:
sudo smartctl -i /dev/sdd 2>/dev/null | grep "Serial Number" || echo "Disk not responding"

# Verify data is accessible
ls -la /mnt/arkk
```

### Step 2: Unmount and Stop Array

```bash
# Unmount the filesystem
sudo umount /mnt/arkk

# Stop the array cleanly
sudo mdadm --stop /dev/md0

# Verify it stopped
cat /proc/mdstat
```

### Step 3: Power Down

```bash
sudo shutdown -h now
```

### Step 4: Physical Disk Swap

1. **Disconnect power** from the system
2. **Open the case** and locate the drives
3. **Find the failed disk by its serial number** (printed on the drive label)
   - Look for: **ZGY8RFGN**
   - Do NOT rely on SATA port numbers - they don't reliably map to device names
4. **Disconnect** the dead drive - both SATA data and power cables
5. **Connect** the cold spare to any available SATA port (doesn't need to be the same port)
6. **Reconnect power** and boot the system

### Step 5: Verify New Disk Detection

> **WARNING**: Device names (sda, sdb, etc.) may change after reboot!
> Always identify disks by serial number, not device letter.

> **NOTE**: If your replacement drive was previously used, you may see unexpected
> partitions on it or inactive `md*` arrays in `/proc/mdstat`. This is normal -
> the drive has old RAID metadata. We'll clean it in Step 6b before adding to the array.

```bash
ssh arkk

# CRITICAL: Identify disks by serial number, not device letter!
lsblk -o NAME,SERIAL,SIZE,MODEL

# Find your NEW spare by matching the serial number you noted earlier
# Example output:
# NAME   SERIAL            SIZE MODEL
# sda    WD-ABC123        3.7T WDC WD4000
# sdb    WD-DEF456        3.7T WDC WD4000
# ...
# sdf    WD-NEW789        3.7T WDC WD4000   <-- your new spare (verify serial!)

# Once you've confirmed which device is the NEW disk, check its health:
sudo smartctl -H /dev/sdX   # Replace sdX with your new disk
# Should say: PASSED

# For the rest of this guide, replace /dev/sdf with your actual new disk device
```

### Step 6: Start Array (Degraded)

```bash
# Let mdadm auto-detect and assemble (safer than hardcoding device names)
sudo mdadm --assemble --scan

# If that fails, assemble by UUID (from mdadm.conf or examine output):
sudo mdadm --assemble --uuid=4ad8134f:b1450118:aa804d2a:d1691d6f /dev/md0

# Check status
cat /proc/mdstat

# Mount the filesystem
sudo mount /dev/md0 /mnt/arkk

# Verify data
ls -la /mnt/arkk
```

### Step 7: Clean the Replacement Drive (if needed)

Check if the replacement drive has existing partitions or RAID metadata:

```bash
# Check for existing partitions
lsblk /dev/sdX   # replace with your new drive

# Check for inactive mdadm arrays using the new drive
cat /proc/mdstat | grep -E "md[0-9]+"
```

If you see partitions on the new drive or inactive `md*` arrays referencing it, clean it:

```bash
# Stop any inactive arrays using the new drive
sudo mdadm --stop /dev/md124   # replace with actual md device names

# Zero old RAID superblocks (for each partition on the new drive)
sudo mdadm --zero-superblock /dev/sdX1
sudo mdadm --zero-superblock /dev/sdX2
# ... repeat for all partitions

# Wipe the partition table
sudo wipefs -a /dev/sdX

# Verify it's clean (should show no partitions)
lsblk /dev/sdX
```

### Step 8: Partition the New Disk

> **DANGER**: Double-check you have the correct disk! Running sfdisk on a
> working RAID member will destroy data and likely the entire array.

```bash
# First, confirm the new disk identity by serial number again:
lsblk -o NAME,SERIAL,SIZE | grep -E "sd[a-z] "

# Identify a working RAID member to copy partition layout from:
sudo mdadm --detail /dev/md0 | grep /dev/sd

# Copy partition table from a working disk to the NEW disk
# VERIFY BOTH DEVICE NAMES ARE CORRECT BEFORE RUNNING!
sudo sfdisk -d /dev/sdX | sudo sfdisk /dev/sdY
#              ^^^^ working disk       ^^^^ NEW disk (verify serial!)

# Verify partition was created on the new disk
lsblk /dev/sdY

# Should show:
# sdY      8:80   0   3.7T  0 disk
# └─sdY1   8:81   0   3.7T  0 part
```

### Step 9: Add New Disk to Array

```bash
# Add the new partition to the array (use your actual device name)
sudo mdadm --manage /dev/md0 --add /dev/sdY1

# Immediately check status
cat /proc/mdstat
```

### Step 10: Monitor Rebuild

The rebuild will take several hours for 4TB disks.

```bash
# Watch progress in real-time
watch -n 5 cat /proc/mdstat

# Example output during rebuild:
# md0 : active raid5 sdf1[6] sdb1[0] sda1[5] sdc1[2] sde1[1]
#       15627540480 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/4] [UUU_U]
#       [>....................]  recovery =  2.3% (91234567/3906885120) finish=487.2min speed=130456K/sec

# Or check occasionally
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

**Expected rebuild time**: 4-8 hours depending on disk speed.

### Step 11: Verify Completion

When rebuild is complete, you should see:

```bash
cat /proc/mdstat
# md0 : active raid5 sdf1[3] sdb1[0] sda1[5] sdc1[2] sde1[1]
#       15627540480 blocks super 1.2 level 5, 512k chunk, algorithm 2 [5/5] [UUUUU]

sudo mdadm --detail /dev/md0
# State : clean
# Active Devices : 5
# Working Devices : 5
# Failed Devices : 0
```

### Step 12: Update mdadm Configuration

After successful rebuild, update the config so the array auto-assembles on boot:

```bash
# Backup current config
sudo cp /etc/mdadm/mdadm.conf /etc/mdadm/mdadm.conf.backup

# Check if array is already defined (avoid duplicates)
grep md0 /etc/mdadm/mdadm.conf

# If NOT already defined, add it:
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

# If already defined, replace the old entry instead:
# sudo mdadm --detail --scan  # copy output
# sudo nano /etc/mdadm/mdadm.conf  # replace old ARRAY line

# Update initramfs
sudo update-initramfs -u
```

---

## Troubleshooting

### If new disk isn't detected after swap

```bash
# Rescan SATA bus
echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan

# Check dmesg for detection
dmesg | tail -50
```

### If sfdisk fails to partition

```bash
# Manually create partition with fdisk
sudo fdisk /dev/sdf
# Commands:
# n (new partition)
# p (primary)
# 1 (partition number)
# Enter (default first sector)
# Enter (default last sector - use whole disk)
# t (change type)
# fd (Linux raid autodetect)
# w (write and exit)
```

### If mdadm --add fails

```bash
# Check for existing superblock
sudo mdadm --examine /dev/sdf1

# If it has old metadata, zero it
sudo mdadm --zero-superblock /dev/sdf1

# Then try add again
sudo mdadm --manage /dev/md0 --add /dev/sdf1
```

### If array won't start

```bash
# Force assembly
sudo mdadm --assemble --force /dev/md0 /dev/sda1 /dev/sdb1 /dev/sdc1 /dev/sde1

# Check for issues
sudo mdadm --examine /dev/sda1 | grep Events
sudo mdadm --examine /dev/sdb1 | grep Events
# All event counts should be the same or very close
```

---

## Post-Recovery Tasks

After the array is fully rebuilt and healthy:

1. **Run a SMART test on all disks**:
   ```bash
   for d in sda sdb sdc sde sdf; do
     sudo smartctl -t short /dev/$d
   done
   # Wait 2 minutes, then check results:
   for d in sda sdb sdc sde sdf; do
     echo "=== $d ===" && sudo smartctl -l selftest /dev/$d | head -10
   done
   ```

2. **Consider adding the dead disk to dead-disk-graveyard** (or RMA if under warranty)

3. **Order another cold spare** if budget allows

4. **Set up SMART monitoring alerts** for early warning:
   ```bash
   sudo apt install smartmontools
   sudo systemctl enable smartd
   ```

5. **Update STORAGE.md** to proceed with PostgreSQL migration once array is healthy

---

## Key Information Reference

- **Array UUID**: 4ad8134f:b1450118:aa804d2a:d1691d6f
- **Array Name**: arkk:0
- **Mount Point**: /mnt/arkk
- **Chunk Size**: 512K
- **Total Capacity**: ~15TB usable (4x data + 1x parity)
- **Filesystem**: (check with `df -T /mnt/arkk`)

---

## Emergency Contacts / Resources

- mdadm man page: `man mdadm`
- Linux RAID wiki: https://raid.wiki.kernel.org/
- SMART monitoring: `man smartctl`
