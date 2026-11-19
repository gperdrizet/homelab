# Network file systems

Audited 2026-11-18. **pyrite is the NFS server**; `arkk` is decommissioned.

## Exports

| Host | Volume | Mount point (server) | Exported to |
|------|--------|----------------------|-------------|
| pyrite | `/dev/md127` (15 TB RAID5, xfs — formerly arkk's array) | `/mnt/arkk` | LAN (`/etc/exports`; exact options to re-verify with `exportfs -v` — needs root) |

## Local (non-NFS) storage

| Host | Volume | Mount | Notes |
|------|--------|-------|-------|
| pyrite | `/dev/bcache0` | `/mnt/fast_scratch` | 2.7 TB bcache (NVMe cache + HDD backstore); holds llama models. See [bcache guide](../machines/pyrite/guides/bcache.md) |
| the-educator | `/dev/sda1` | `/home/siderealyear/big_itch` | 3.6 TB, local |
| the-educator | `/dev/sdc1` | `/home/siderealyear/ark` | 3.6 TB, local |

## Clients

| Client | fstab entry | Status |
|--------|-------------|--------|
| hugo | `10.1.10.200:/mnt/arkk /mnt/arkk nfs rw,hard,sync,noatime,nofail` | configured; **not currently mounted** |
| the-educator | `10.1.10.202:/mnt/arkk ...` | **BROKEN — points at decommissioned arkk**, no `nofail`; can stall boot ~90 s. Should be repointed to `10.1.10.200` or removed. |

## Fix list

1. the-educator: replace the dead `10.1.10.202` entry with
   `10.1.10.200:/mnt/arkk ... ,nofail` (or drop it if no longer wanted).
2. hugo: verify the mount actually comes up (`mount /mnt/arkk`).
3. Record `exportfs -v` output here for the authoritative export options.

## Historical

arkk's bonded `lan-data` (10.1.10.202) and the pyrite direct link
(192.168.2.0/24) documented here previously are retired with the machine — see
[archive/arkk](../archive/arkk/README.md).
