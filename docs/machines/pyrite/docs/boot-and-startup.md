# Boot and startup

Boot and login optimization log for pyrite.

Outcome:
- Baseline boot time improved from about 2m28s to about 40s to graphical target.

## Startup strategy

1. Use socket activation for Docker:
- Disable eager daemon start:
  - sudo systemctl disable docker containerd
- Enable docker socket:
  - sudo systemctl enable docker.socket

2. Disable non-essential boot services:
- containerd
- lvm2-monitor
- gnome-remote-desktop
- apport

Command:
- sudo systemctl disable containerd lvm2-monitor gnome-remote-desktop apport

3. Reduce snap loop mounts:
- Migrated Firefox, Thunderbird, and Steam from snap to apt.
- Kept only required snaps for livepatch.

4. Fix NFS boot blocking:
- Updated ark.service and big_itch.service to use network-online.target.
- Added TimeoutStartSec to avoid long hangs when NAS is unavailable.

5. Remove legacy tunnel services from boot path:
- wg-quick@wg0 disabled and archived.
- dev-tunnel.service disabled.
- logkeep-tunnel.service disabled.

6. Warm reboot reliability:
- Kernel params in /etc/default/grub:
  - reboot=efi nvidia.NVreg_PreserveVideoMemoryAllocations=0

## Remaining optional optimization

- nvidia-cdi-refresh.service can be disabled if GPU passthrough in containers is not needed.
  - sudo systemctl disable nvidia-cdi-refresh.service

## Verification checklist

Boot critical chain:
- systemd-analyze critical-chain

Boot blame:
- systemd-analyze blame

Service status checks:
- systemctl status docker.socket
- systemctl status ark.service big_itch.service
- systemctl status tailscaled

## Revert references

- Re-enable docker and containerd eager startup:
  - sudo systemctl enable docker containerd
  - sudo systemctl disable docker.socket
