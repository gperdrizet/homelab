# Troubleshooting

Issue-focused troubleshooting notes for pyrite platform operations.

## Warm reboot hang

Symptom:
- systemctl reboot hangs at black screen.

Current fix:
- reboot=efi nvidia.NVreg_PreserveVideoMemoryAllocations=0 in grub cmdline.

If issue returns:
- install rasdaemon and capture machine check events.
- review previous boot logs:
  - journalctl -b -1 -p err --no-pager
  - dmesg | grep -iE "mce|machine check"

## Firefox startup crash after snap to apt migration

Symptom:
- stale parentlock and Firefox crash on launch.

Cause:
- AppArmor profile missing ~/.config/mozilla access.

Fix location:
- /etc/apparmor.d/usr.bin.firefox

Reload profile:
- sudo apparmor_parser -r /etc/apparmor.d/usr.bin.firefox

Note:
- Firefox package updates may overwrite profile changes.

## Wayland app launch regressions

VS Code blank or fails to open:
- remove ~/.config/code-flags.conf

Chrome startup regression:
- remove ~/.config/chrome-flags.conf
- reset experimental chrome flags to defaults

OBS no screen capture devices:
- replace XSHM sources with PipeWire sources

Zoom second-share black screen:
- run Zoom in XWayland mode via QT_QPA_PLATFORM=xcb
