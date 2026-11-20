# Network file systems

Audited 2026-11-18, re-verified 2026-11-20. **pyrite is the NFS server**;
`arkk` is decommissioned.

## Exports (from `/etc/exports` on pyrite, verified 2026-11-20 — file content matches this table exactly)

| Export | Clients | Options |
|--------|---------|---------|
| `/mnt/arkk` (15 TB RAID5, xfs — formerly arkk's array) | `10.1.10.0/24` | `rw,async,no_subtree_check,no_root_squash` |
| `/mnt/fast_scratch` (2.7 TB bcache) | `10.1.10.0/24` | `rw,async,no_subtree_check,no_root_squash` |

!!! warning
    `no_root_squash` + `async` on both: any root on a LAN client can write as
    real root, and writes are not crash-safe. Acceptable on a trusted home LAN
    but worth an explicit decision. Exporting all of `fast_scratch` may also be
    broader than intended.

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
| the-educator | `10.1.10.200:/mnt/arkk /home/siderealyear/arkk nfs ro,nofail` | **mounted (ro)** — repointed from dead `10.1.10.202` to pyrite on 2026-11-20; verified up as nfs4.2 (archive data window, not boot-critical) |

## Fix list

1. ~~the-educator: replace the dead `10.1.10.202` entry~~ — **done 2026-11-20**:
   now `10.1.10.200:/mnt/arkk /home/siderealyear/arkk nfs ro,nofail`, mount
   verified (nfs4.2).
2. hugo: verify the mount actually comes up (`mount /mnt/arkk`).
3. ~~Record `exportfs -v` output here~~ — `/etc/exports` re-read 2026-11-20 and
   matches the table above verbatim.

## NFS servers besides pyrite

`the-educator` also runs an NFS server (`nfs-server` unit, listening on
2049): it exports its own local disks to the LAN —
`/home/siderealyear/ark` and `/home/siderealyear/big_itch`, both
`rw,no_root_squash,no_subtree_check,async`. No machine on the LAN currently
mounts from it (checked 2026-11-20). Same `no_root_squash` + `async`
caveats as the pyrite exports above apply.

## Historical

arkk's bonded `lan-data` (10.1.10.202) and the pyrite direct link
(192.168.2.0/24) documented here previously are retired with the machine — see
[archive/arkk](../archive/arkk/README.md).
