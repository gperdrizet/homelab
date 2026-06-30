# Local network: bonded link and LAN layout

---

## LAN

All home-office machines connect to the internet via a standard home router.
No services are exposed directly from the LAN; all public endpoints run on
gatekeeper (VPS).

| Device  | LAN interface | LAN IP | Notes |
|---------|---------------|--------|-------|
| pyrite  | <!-- e.g. eth0 --> | <!-- e.g. 192.168.1.x --> | Primary LAN adapter |
| arkk    | <!-- e.g. eth0 --> | <!-- e.g. 192.168.1.x --> | Primary LAN adapter |

---

## Direct bonded link (pyrite ↔ arkk)

pyrite and arkk are connected by dedicated Ethernet cables bonded together for
higher throughput and redundancy. This link is used exclusively for NFS storage
traffic (backups, large file access), keeping that load off the main LAN.

### pyrite side

```
# TODO: document after arkk is restored
Interface: <!-- e.g. bond0 -->
Members:   <!-- e.g. eth1 + eth2 -->
IP:        <!-- e.g. 192.168.10.1/24 -->
Mode:      <!-- e.g. active-backup / 802.3ad LACP -->
```

### arkk side

```
Interface: <!-- e.g. bond0 -->
Members:   <!-- e.g. eth1 + eth2 -->
IP:        <!-- e.g. 192.168.10.2/24 -->
```

### NFS mount (pyrite)

```
# TODO: document NFS mount config once arkk is restored
# /etc/fstab entry on pyrite:
# <arkk-ip>:/export/data  /mnt/arkk  nfs  defaults,_netdev  0  0
```
