# Change log

## 2026-06

- Completed pyrite Wayland switchover and app-specific compatibility fixes.
- Consolidated to Tailscale-only tunnel model; retired WireGuard and autossh tunnels.
- Reworked boot path and service ordering, reducing boot time to about 40 seconds.
- Fixed warm reboot reliability with UEFI reboot path kernel parameter.
- Installed VS Code tunnel as a persistent user systemd service.
- Migrated Firefox, Thunderbird, and Steam from snap to apt to reduce startup overhead.

## Historical source docs

The following operational notes were consolidated into this directory:
- /home/siderealyear/admin/system-setup/TODO.md
- /home/siderealyear/admin/system-setup/boot-optimization.md
- /home/siderealyear/admin/system-setup/system-tuning.md
- /home/siderealyear/admin/system-setup/vscode-tunnel.md
- /home/siderealyear/admin/system-setup/wayland-switchover.md
