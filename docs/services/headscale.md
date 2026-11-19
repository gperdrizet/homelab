# Headscale tailnet control

Self-hosted [Headscale](https://github.com/juanfont/headscale) replaces the
Tailscale cloud control plane. Runs on gatekeeper; [Headplane](https://github.com/tale/headplane)
provides the web UI.

| Item | Value |
|------|-------|
| Headscale | systemd service on gatekeeper, API `:8090` → headscale.perdrizet.org |
| Headplane | container, `127.0.0.1:3001` → headplane.perdrizet.org |
| MagicDNS domain | ts.perdrizet.org |
| Subnet | 100.64.0.0/24 |

Current device table and exit-node notes: [network/tailnet.md](../network/tailnet.md).

Setup scripts and historical install notes live in
[machines/gatekeeper/tailnet/](../machines/gatekeeper/tailnet/README.md).
