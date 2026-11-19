# Tailscale / Headscale

The homelab runs a self-hosted [Headscale](https://github.com/juanfont/headscale)
control server (systemd on gatekeeper) in place of the Tailscale cloud. See
also the [Headscale service page](../services/headscale.md).

- **Public endpoint:** headscale.perdrizet.org
- **UI (Headplane):** headplane.perdrizet.org
- **MagicDNS domain:** ts.perdrizet.org
- **Subnet:** 100.64.0.0/24

## Devices

From `tailscale status` on pyrite, 2026-11-18:

| Device | Tailnet IP | OS | Role |
|--------|-----------|----|------|
| gatekeeper | 100.64.0.1 | Ubuntu | Control server, **exit node** |
| pyrite | 100.64.0.2 | Ubuntu | Core services host |
| laptop | 100.64.0.3 | — | offline (200+ days) — candidate for removal |
| ethics-gradient | 100.64.0.5 | Ubuntu | Desktop client |
| voxxel | 100.64.0.6 | Android | Mobile client |

**Not enrolled:** the-educator, hugo.

> Old docs listed voxxel at 100.64.0.4 — current allocation is 100.64.0.6.

## Conventions

- Services bind tailnet or localhost addresses; consumers use `100.64.0.x` or
  MagicDNS names.
- gatekeeper is the only machine with meaningful public exposure.

## TODO

- Remove stale `laptop` node from Headscale (or document why it's kept).
- Decide whether the-educator and hugo should enroll (enables admin without
  LAN-only access).
- pyrite's `laptop` IP `100.64.0.4` may be free now — don't assume, check
  `headscale nodes list`.
