# Machines

High-level inventory of homelab machines and their roles.

| Machine | Role | Status | Docs |
|---------|------|--------|------|
| gatekeeper | Public VPS, ingress, monitoring, app hosting | Active | [gatekeeper](machines/gatekeeper/README.md) |
| pyrite | Desktop development and compute host | Active | [pyrite](machines/pyrite/README.md) |
| arkk | NAS and storage plane | Active | [arkk](machines/arkk/README.md) |

## Notes

- Public traffic terminates on gatekeeper.
- pyrite services are consumed through private tailnet paths.
- arkk is the primary NAS and backup target.
