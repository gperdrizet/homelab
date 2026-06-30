# Pyrite platform TODO

Open platform-level tasks after consolidation.

## Wayland app verification

- [ ] Firefox: confirm account sync restored after migration.
- [ ] Thunderbird: finish account setup and connectivity test.
- [ ] Steam: complete first-run validation and render test.
- [ ] Zoom: verify repeated stop/start share stability in current launch mode.

## Networking and cleanup

- [ ] Remove stale archived WireGuard config notes where no longer needed.
- [ ] Remove stale gatekeeper nginx comment referring to WireGuard tunnel path.
- [ ] Remove one-off helper scripts no longer used after tailnet migration.

## Hardware and observability

- [ ] Install rasdaemon and enable persistent MCE capture.
- [ ] Check Supermicro X9SRA-3 BIOS updates and compatibility notes.

## Startup optimization

- [ ] Decide on nvidia-cdi-refresh.service disablement based on current container GPU passthrough needs.
