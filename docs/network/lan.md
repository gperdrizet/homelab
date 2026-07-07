# Local network: LAN layout

## Overview

All `interesting-times-gang` machines connect to the internet via a standard home router.
No services are exposed directly from the LAN; all public endpoints run on
gatekeeper (VPS). Network configuration is done via netplan configuration at `/etc/netplan/01-netcfg.yaml`. 

| Device         | LAN interface | IP            | Notes                               |
|----------------|---------------|---------------|-------------------------------------|
| `pyrite`       | lan-ssh       | 10.1.10.200   | Primary LAN adapter, SSH access     |
| `pyrite`       | arkk-link     | 192.168.2.2   | Direct data link to arkk            |
| `arkk`         | lan-ssh       | 10.1.10.201   | Primary LAN adapter, SSH access     |
| `arkk`         | pyrite-link   | 192.168.2.1   | Direct data link to pyrite          |
| `arkk`         | lan-data      | 10.1.10.202   | Dual bonded data link for LAN hosts |
| `the-educator` | lan           | 10.1.10.204   | Primary LAN adapter                 |
| `voxxel`       | wifi          | 10.1.10.203   | Phone wifi                          |
| `gatekeeper`   |               | 74.208.107.78 | Gatekeeper public IP                |

## `arkk` lan-data interface

The lan-data interface on `arkk` is a bond of two gigabit ethernet adapters:

- **data0**, MAC address: 00:0b:0e:0f:00:ed
- **data1**, MAC address: 00:11:0e:26:35:28

```yaml
# /etc/netplan/01-netcfg.yaml

    data0:
      match:
        macaddress: 00:0b:0e:0f:00:ed
      set-name: data0
      dhcp4: no
    data1:
      match:
        macaddress: 00:11:0e:26:35:28
      set-name: data1
      dhcp4: no
  bonds:
    lan-data:
      interfaces:
        - data0
        - data1
      addresses: [10.1.10.202/24]
      parameters:
        mode: balance-alb
        mii-monitor-interval: 100
```

The link runs in `balance-alb` (adaptive load balancing) mode to distribute traffic across both NIC's when multiple hosts are hitting the RAID array.

## LAN interfaces

On `pyrite` and `arkk` the lan-ssh link caries all traffic other than nfs mounts. On the educator, the single lan link handles everything.

Static IPv4 addresses are assigned via netplan. Interface names are assigned via MAC address matching. IPv6 is disabled. Example lan-ssh netplan configuration stanza from `pyrite`:

```yaml
# /etc/netplan/01-netcfg.yaml

    lan-ssh:
      match:
        macaddress: 0c:c4:7a:47:63:ac
      set-name: lan-ssh
      dhcp6: false
      accept-ra: false
      link-local: []
      addresses: [10.1.10.200/24]
      nameservers:
        addresses: [1.1.1.1, 1.0.0.1, 8.8.8.8]
      routes:
      - to: default
        via: 10.1.10.1
      optional: true
```

## Host names

Host names are configured in `/etc/hosts`. The loopback is given a FQDN to distinguish it from the host's network address. Here is `pyrite`:

```text
# /etc/hosts
127.0.0.1 localhost
127.0.1.1 pyrite.local pyrite

::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

10.1.10.204 the-educator
10.1.10.202 arkk
10.1.10.200 pyrite
100.64.0.1 gatekeeper
74.208.107.78 gatekeeper-public-ip
```

SSH hosts are also set in `~/.ssh/config`:

```text
Host arkk
    HostName 10.1.10.201
    User siderealyear
    Port 22

Host gatekeeper
    HostName 100.64.0.1
    User siderealyear
    Port 44441
    ForwardAgent yes

Host gatekeeper-public-ip
    HostName 74.208.107.78
    User siderealyear
    Port 44441
    ForwardAgent yes

Host pyrite
    HostName 10.1.10.200
    User siderealyear
    Port 4444

Host the-educator
    HostName 10.1.10.204
    User siderealyear
    Port 22
```

