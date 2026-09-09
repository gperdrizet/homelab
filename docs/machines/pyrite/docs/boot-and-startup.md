# Boot and startup

Boot and login optimization log for pyrite.

Outcome:
- Baseline boot time improved from about 2m28s to about 40s to graphical target.

## Startup strategy

1. Keep container workloads out of the boot path:

Anything `WantedBy=multi-user.target` is implicitly ordered `Before` it, and
`graphical.target` (so GDM) waits on `multi-user.target`. Docker takes ~50s to
restore containers, so leaving it enabled delays the login screen by that much.

- Docker is reached on demand through socket activation:
  - `sudo systemctl enable docker.socket`
  - `sudo systemctl disable docker.service`
- Container workloads start after boot via a timer rather than at boot:
  - `/etc/systemd/system/containers-late.timer` (`OnBootSec=20s`)
  - `/etc/systemd/system/containers-late.service` starts `docker.service`,
    `jupyterlab.service`, `postgressql-server-stack.service` and the GitHub
    Actions runner with `systemctl start --no-block`.
- `containerd.service` needs no separate handling; `docker.service` pulls it.

**This regresses on Docker package upgrades.** `docker-ce` postinst runs
`systemctl enable docker.service`, putting it back in `multi-user.target`.
Re-check after upgrades:

- `ls /etc/systemd/system/multi-user.target.wants/ | grep -E 'docker|jupyter'`
  should return nothing.
- `systemd-analyze critical-chain graphical.target` should not list
  `docker.service`.

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
