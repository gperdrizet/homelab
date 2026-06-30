# Pyrite platform baseline

Canonical workstation baseline for pyrite.

System profile:
- Host: pyrite
- OS: Ubuntu 24.04 LTS
- Desktop: GNOME
- Display stack: Wayland user sessions, X11 GDM greeter
- GPU: NVIDIA (GTX 1070 and Tesla P100)
- Tailnet IP: 100.64.0.2

## Current architecture decisions

1. Networking and ingress:
- Tailscale is the only tunnel fabric for pyrite service access.
- Public ingress terminates on gatekeeper; gatekeeper proxies to pyrite over tailnet.
- Legacy WireGuard and autossh tunnels are retired.

2. Service bind posture:
- OpenVSCode Server binds to 100.64.0.2.
- JupyterLab binds to 100.64.0.2.
- pyrite core services are consumed through gatekeeper proxying where applicable.

3. Desktop session posture:
- GDM greeter runs X11 for faster login handoff on NVIDIA.
- User session defaults to Wayland for day-to-day desktop use.

4. Performance defaults:
- vm.swappiness=10
- kernel.numa_balancing=1
- GNOME Mutter check-alive-timeout=15000

## Baseline settings and verification

Kernel and scheduler tuning:
- Config file: /etc/sysctl.d/99-perf.conf
- Values:
  - vm.swappiness=10
  - kernel.numa_balancing=1

Apply:
- sudo sysctl -p /etc/sysctl.d/99-perf.conf

Verify:
- sysctl vm.swappiness kernel.numa_balancing

GNOME Mutter timeout:
- gsettings set org.gnome.mutter check-alive-timeout 15000

Verify:
- gsettings get org.gnome.mutter check-alive-timeout

GDM greeter on X11 while preserving Wayland sessions:
- Flag file: /etc/tmpfiles.d/gdm-greeter-x11.conf
- Expected content:
  - f /run/gdm/disable-wayland 0644 root root -

Apply immediately:
- sudo systemd-tmpfiles --create /etc/tmpfiles.d/gdm-greeter-x11.conf

## Core pyrite services

See https://github.com/gperdrizet/homelab/blob/main/docs/machines/pyrite/services/README.md for full service inventory and external repo links.

## Open follow-ups

- Remove stale archived WireGuard artifacts and comments in gatekeeper nginx notes.
- Confirm Firefox sync restoration after snap to apt migration.
- Complete app validation matrix in wayland-and-av.md.
