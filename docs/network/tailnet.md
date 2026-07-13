# Tailscale / Headscale

The homelab uses a self-hosted Headscale control server (running on gatekeeper)
in place of the Tailscale cloud control plane. All devices connect to it to form
a private mesh network (tailnet).

---

## Control server

**Software:** [Headscale](https://github.com/juanfont/headscale) (systemd service on gatekeeper)  
**UI:** [Headplane](https://github.com/tale/headplane) at headplane.perdrizet.org  
**Public endpoint:** headscale.perdrizet.org  
**MagicDNS domain:** ts.perdrizet.org  
**Subnet:** 100.64.0.0/24  

Setup scripts and configs: [machines/gatekeeper/tailnet](../machines/gatekeeper/tailnet/README.md)

---

## Devices

| Device     | Hostname   | Tailscale IP | OS      | Role                          |
|------------|------------|--------------|---------|-------------------------------|
| gatekeeper | gatekeeper | 100.64.0.1   | Ubuntu  | Exit node (advertised)        |
| pyrite     | pyrite     | 100.64.0.2   | Ubuntu  | Client, exit node enabled     |
| laptop     | laptop     | 100.64.0.3   | Unknown | Client                        |
| voxxel     | voxxel     | 100.64.0.4   | Android | Mobile client                 |
| arkk       | arkk       | TBD          | Ubuntu  | Not currently enrolled        |

---

## Exit node

gatekeeper advertises itself as an exit node. All client devices (including
pyrite and mobile) route internet traffic through gatekeeper by default.

---

## Tailscale-only services

Several services on gatekeeper are bound to the Tailscale IP (100.64.0.1) and
are not reachable from the public internet:

| Service | Address |
|---------|---------|
| model-gateway adminer | 100.64.0.1:8504 |
| model-gateway staging | 100.64.0.1:8505 |
| model-gateway adminer (staging) | 100.64.0.1:8506 |
| bug-hunter staging | 100.64.0.1:8507 |
| logkeep staging | 100.64.0.1:8003 (nginx only) |
| bench staging | 100.64.0.1:8012 (nginx only) |
| BTCPay (stopped) | 100.64.0.1:23000 |
