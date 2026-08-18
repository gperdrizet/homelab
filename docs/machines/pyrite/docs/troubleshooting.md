# Troubleshooting

Issue-focused troubleshooting notes for pyrite platform operations.

## Black screen on Wayland login (multi-GPU)

Symptom:
- GDM greeter works, but after login displays flicker then go black with a
  movable cursor indefinitely.
- Xorg sessions still log in but are slow.
- Desktop apps (Zoom, browsers) lag badly, worsening over time.

Cause:
- The two Tesla P100s are compute-only and have no display connectors, but
  logind tagged them onto `seat0`, so mutter opened all three GPUs as DRM
  master and built a GBM renderer on each:
  `Created gbm renderer for '/dev/dri/card1'` (P100).
- llama.cpp saturates both P100s, so mutter stalls on GBM/DRM operations
  against them. The cursor keeps moving because it is a hardware plane on the
  GTX 1070.

Fix:
- `/etc/udev/rules.d/74-drm-skip-compute-gpus.rules` strips the `seat` and
  `master-of-seat` tags from the P100 DRM card nodes.
- The rule must sort **after** `/usr/lib/udev/rules.d/71-seat.rules`, which
  applies the tags. A lower number (e.g. `61-`) silently does nothing.

Apply:
- `sudo udevadm control --reload`
- `sudo udevadm trigger --subsystem-match=drm --action=change`

Verify:
- `loginctl seat-status seat0 | grep drm:card` shows only `card0`.
- `udevadm info -q property /sys/class/drm/card1 | grep CURRENT_TAGS` has no
  `seat` tag. Use `CURRENT_TAGS`, not `TAGS`; `TAGS` is cumulative history and
  keeps showing removed tags.
- After login: only one `Created gbm renderer` line in the journal.

Note:
- Display-layer only. CUDA uses `/dev/nvidia*`, so llama.cpp and the
  JupyterLab container are unaffected.

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
