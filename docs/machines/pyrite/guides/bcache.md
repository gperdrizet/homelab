# Bcache setup

## Hardware

Pyrite has a 1 TB NVMe SSD plugged into a PCIe slot via an adapter card that acts as a read/write cache for a 3.7 TB RAID0 of SATA HDDs.

- **Cache drive**: `/dev/nvme0n1`, UUID: `e7a125f0-ec82-4855-af09-a7c59c970fc2`, ext4
- **RAID0**: `/dev/md0`, UUID: `95e5c98c-2116-4544-9613-42d7f00031b6`, ext4
    - `/dev/sda`, UUID_SUB: `45d7ad60-755d-c831-2aca-95f4436af57e`
    - `/dev/sdb`, UUID_SUB: `b81b6c38-ffde-fa79-d016-77da91d9fce0`
    - `/dev/sdd`, UUID_SUB: `e83eb99f-b63c-88db-cda0-bbf3fcc705c8`

## 1. Prerequisites

Install tools:

```text
sudo apt update
sudo apt install bcache-tools mdadm -y
```

## 2. Prepare block devices

Both the cache disk and the RAID need to be wiped.

### 2.1. Unmount volumes

```text
sudo umount /dev/md0
sudo mdadm --stop /dev/md0
```

Umount the SSD:

```text
sudo umount /mnt/fast_scratch
```

If target is busy, find out what's using it with:

```text
sudo fuser -m -v /mnt/fast_scratch
```

### 2.2. Wipe individual drives

Then wipe the file system on all volumes:

```text
sudo wipefs -a /dev/nvme0n1
sudo wipefs -a /dev/sda /dev/sdb /dev/sdd
```

## 3. Create cached volume

Now we create a RAID0 with the HDDs and use it in a bcache device with the SSD.

### 3.1. Create RAID0

```text
sudo mdadm --create --verbose /dev/md0 --level=0 --raid-devices=3 /dev/sda /dev/sdb /dev/sdd
```

Save the configuration so it gets assembled on boot:

```text
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

### 3.2. Create bcache device

```text
sudo make-bcache -B /dev/md0 -C /dev/nvme0n1
```

### 3.3. Register devices

```text
echo "/dev/md0" | sudo tee /sys/fs/bcache/register
echo "/dev/nvme0n1" | sudo tee /sys/fs/bcache/register
```

## 4. Set-up the new bcache device

### 4.1. Format

```text
sudo mkfs.ext4 /dev/bcache0
```

### 4.2. Set cache mode

Set the cache to run in writeback mode:

```text
echo writeback | sudo tee /sys/block/bcache0/bcache/cache_mode
```

### 4.3. Mount

Find the bcache's UUID:

```text
sudo blkid /dev/bcache0
```

Then add the following to `/etc/fstab`:

```text
# /etc/fstab
UUID=your-bcache0-uuid-here  /mnt/storage  ext4  defaults,nofail  0  2
```