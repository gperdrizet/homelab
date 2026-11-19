# hugo

Raspberry Pi 0 W. Barely doing anything yet — by design.

## Hardware

**Board:** Raspberry Pi 0 W (ARMv6, 512 MB RAM)
**Storage:** 16 GB SD card
**OS:** Raspbian 11 (bullseye)

## Network

- LAN: `10.1.10.143`
- Not enrolled in the tailnet.

## Current state

Stock-ish: ssh, avahi, wpa_supplicant. No containers, no exported services.
fstab references `pyrite:/mnt/arkk` at `/mnt/arkk` (not currently mounted).

## Ideas (parking lot)

DNS node, network monitoring probe, tailnet enrollment, gpio experiments.
