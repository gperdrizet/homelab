# Network file systems

| Host           | Volume      | Mount                         | RAID | Size (TB)   | Exported IP  |
|----------------|-------------|-------------------------------|------|-------------|--------------|
| `the-educator` | `/dev/sdc1` | `/home/siderealyear/ark`      |  5   |    3.6      | 10.1.10.0/24 |
| `the-educator` | `/dev/sda1` | `/home/siderealyear/big_itch` |  NA  |    3.6      | 10.1.10.0/24 |
| `arkk`         | `/dev/md0`  | `/mnt/arkk`                   |  5   |    15.0     | 192.168.2.2  |
| `arkk`         | `/dev/md0`  | `/mnt/arkk`                   |  5   |    15.0     | 10.1.10.0/24 |

Arkk's RAID is avalible via a dual bonded link in mode `balance-alb` to any host on the LAN at 10.1.10.202:

```bash
# /etc/exports
/mnt/arkk 10.1.10.0/24(rw,no_root_squash,no_subtree_check,async)
```


### NFS mounts

Pyrite mounts arkk's RAID via nfs:

#### pyrite

Direct data link to `arkk` RAID is mounted via `etc/fstab`.

```bash
# /etc/fstab
192.168.2.1:/mnt/arkk /mnt/arkk nfs rw,hard,sync,noatime,nfsvers=4 0 0
```

Drives on `the-educator` (`ark` & `big_itch`) are mounted via systemd to avoid issues with boot order/timing of network interface availability. Does not seem to be a problem with `arkk`, probably because it's a direct link with no switch or router.

##### `ark/`

Archival storage RAID 5 (3.6 TB) on `the-educator`. Here is the systemd unit file contents:

```text
#/etc/systemd/system/ark.service 

[Unit]
Description=Ark NFS RAID mount
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/bin/mount -t nfs4 10.1.10.204:/home/siderealyear/ark /mnt/ark
ExecStop=/usr/bin/umount /mnt/ark
Restart=on-failure
RestartSec=10
TimeoutStartSec=30

[Install]
WantedBy=multi-user.target
```

##### `big_itch/`

Single large SATA HDD (3.6 TB) - use for overflow, steam library etc., where to stick stuff when we aren't sure where else to put it.

```
#/etc/systemd/system/ark.service 

[Unit]
Description=Big itch NFS mount
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/usr/bin/mount -t nfs4 10.1.10.204:/home/siderealyear/big_itch /mnt/big_itch
ExecStop=/usr/bin/umount /mnt/big_itch
Restart=on-failure
RestartSec=10
TimeoutStartSec=30

[Install]
WantedBy=multi-user.target
```

#### Arkk side

```bash
# /etc/exports
/mnt/arkk 192.168.2.2(rw,no_root_squash,no_subtree_check,async)
```
