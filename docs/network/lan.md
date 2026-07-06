# Local network: bonded link and LAN layout

---

## LAN

All home-office machines connect to the internet via a standard home router.
No services are exposed directly from the LAN; all public endpoints run on
gatekeeper (VPS).

| Device  | LAN interface | LAN IP | Notes |
|---------|---------------|--------|-------|
| pyrite  | lan-ssh | 10.1.10.200/24 | Primary LAN adapter |
| arkk    | eth (onboard) | 10.1.10.201/24 | Primary LAN adapter, SSH access |

---

## Direct bonded link (pyrite ↔ arkk)

pyrite and arkk are connected by dedicated Ethernet cables bonded together for
higher throughput and redundancy. This link is used exclusively for NFS storage
traffic (backups, large file access), keeping that load off the main LAN.

### pyrite side

```
Interface: bond0
Members:   data0 + data1 (2 × 1000 Mbps)
IP:        192.168.2.2/24
Mode:      balance-rr (round-robin)
```

Measured throughput: ~200 MB/s aggregate (iperf); a single TCP stream sees
less due to round-robin packet reordering — use parallel streams for bulk
transfers.

### arkk side

```
Interface: bond0
Members:   dual gigabit pair (direct-wired to pyrite data0/data1)
IP:        192.168.2.1/24
```

### NFS mount (pyrite)

During the 2026 recovery the mount is established manually, read-only:

```bash
# arkk exports /mnt/arkk read-only to pyrite (192.168.2.2)
sudo mount -t nfs4 -o ro,hard,noatime,nosuid,nodev,noexec \
  192.168.2.1:/mnt/arkk /mnt/arkk
```

Normal (post-recovery) fstab entry on pyrite — currently commented out until
the array returns to read-write service:

```
# /etc/fstab
192.168.2.1:/mnt/arkk  /mnt/arkk  nfs  rw,hard,sync,noatime,nfsvers=4  0  0
```
