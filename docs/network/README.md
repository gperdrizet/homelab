# Network

Overview of the homelab network topology: how the three machines connect to each
other and to the internet.

---

## Topology

```
Internet
    │
    ├── 74.208.107.78 (public IP)
    │       │
    │   [gatekeeper]  ── Tailscale 100.64.0.1 (exit node)
    │
    └── Home LAN (router, 10.1.10.0/24)
            │
            ├── [pyrite] 10.1.10.200 ── Tailscale 100.64.0.2
            │       │
            │       └── arkk-link 192.168.2.2 ═══════ pyrite-link 192.168.2.1
            │           (direct link)                         │
            └── [arkk] 10.1.10.201 ──────────────────────┘
                (NFS over direct link; Tailscale currently inactive)
```

---

## Tailscale / Headscale

See [tailnet.md](tailnet.md) for full details.

**Control server:** Headscale at headscale.perdrizet.org (running on gatekeeper)  
**MagicDNS domain:** ts.perdrizet.org  

| Device     | Hostname   | Tailscale IP | Role                              |
|------------|------------|--------------|-----------------------------------|
| gatekeeper | gatekeeper | 100.64.0.1   | Exit node (advertised)            |
| pyrite     | pyrite     | 100.64.0.2   | Client, exit node enabled         |
| laptop     | laptop     | 100.64.0.3   | Client                            |
| voxxel     | voxxel     | 100.64.0.4   | Android client                    |
| arkk       | arkk       | TBD          | Not currently enrolled            |

All client devices route internet traffic through gatekeeper (exit node).

---

## Local LAN

All home-office machines (pyrite, arkk) connect to the internet via a standard
home router/ISP connection. No static public IP on the LAN; all public services
run on gatekeeper.

---

## Direct link (pyrite ↔ arkk)

pyrite and arkk are connected by a dedicated Ethernet link used for NFS
storage traffic, keeping backup and file access off the main LAN.

See [lan.md](lan.md) for interface names, IP addresses, and bonding configuration.
