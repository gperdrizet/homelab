# Repo consolidation (2026)

Historical record of the consolidation of the `admin/` and `vps-infrastructure/`
repositories into `homelab` as the single source of truth. Completed July 2026.

## Scope and ownership decisions

- `/home/siderealyear/admin/`: durable runbooks and machine/service/network
  notes migrated into this repo; admin docs retired.
- `/home/siderealyear/vps-infrastructure/`: gatekeeper infrastructure docs,
  configs, compose files, scripts, and tailnet assets migrated; external repo
  retired.
- `/home/siderealyear/llama.cpp` and `/home/siderealyear/postgreSQL-server`:
  remain independent service repos. Homelab documents deployment topology,
  ingress paths, dependencies, and operational references only.
- Secrets were excluded from migration. Secret values remain outside git per
  [secrets management](../secrets/README.md).

## File-by-file migration record

### admin -> homelab

- [x] `arkk-backup-list.md` -> `docs/machines/arkk/BACKUP_TRIAGE_2026.md`
- [x] `system-setup/boot-optimization.md` -> consolidated into `docs/machines/pyrite/docs/boot-and-startup.md`
- [x] `system-setup/system-tuning.md` -> consolidated into `docs/machines/pyrite/docs/platform-baseline.md` and `docs/machines/pyrite/docs/troubleshooting.md`
- [x] `system-setup/vscode-tunnel.md` -> consolidated into `docs/machines/pyrite/docs/remote-access.md`
- [x] `system-setup/wayland-switchover.md` -> consolidated into `docs/machines/pyrite/docs/wayland-and-av.md`
- [x] `system-setup/TODO.md` -> consolidated into `docs/machines/pyrite/docs/TODO.md`
- [x] `obs-audio.md` -> migrated to `docs/machines/pyrite/guides/obs-audio.md`
- [x] `obs-video.md` -> migrated to `docs/machines/pyrite/guides/obs-video.md`
- [x] `new-machine-build-plan.md` -> migrated to `docs/machines/pyrite/guides/ml-workstation-build-plan.md`
- [x] `vscode-google-cloud-setup-notes.md` -> migrated to `docs/machines/pyrite/guides/google-cloud-remote-dev.md`
- [x] `wish-list.md` -> folded into `docs/machines/pyrite/docs/TODO.md` (hardware wishlist section)
- [x] `secrets/*` -> excluded from git docs migration; policy tracked in `docs/secrets/README.md`

### vps-infrastructure -> homelab

- [x] `README.md` -> consolidated into `docs/machines/gatekeeper/README.md`
- [x] `docs/services.md` -> `docs/machines/gatekeeper/docs/services.md`
- [x] `docs/infrastructure-layout.md` -> `docs/machines/gatekeeper/docs/infrastructure-layout.md`
- [x] `docs/backup-improvements.md` -> `docs/machines/gatekeeper/docs/backup-improvements.md`
- [x] `docs/IMPLEMENTATION-GUIDE.md` -> `docs/machines/gatekeeper/docs/IMPLEMENTATION-GUIDE.md` (historical)
- [x] `docs/phase3-summary.md` -> `docs/machines/gatekeeper/docs/phase3-summary.md` (historical)
- [x] `docker-compose.core.yml` -> `docs/machines/gatekeeper/docker-compose.core.yml`
- [x] `docker-compose.monitoring.yml` -> `docs/machines/gatekeeper/docker-compose.monitoring.yml`
- [x] `compose/*` -> `docs/machines/gatekeeper/compose/*`
- [x] `configs/*` -> `docs/machines/gatekeeper/configs/*`
- [x] `scripts/*` -> `docs/machines/gatekeeper/scripts/*`
- [x] `tailnet/README.md` -> `docs/machines/gatekeeper/tailnet/README.md`
- [x] `tailnet/docs/manual-steps.md` -> `docs/machines/gatekeeper/tailnet/docs/manual-steps.md`
- [x] `tailnet/configs/*` -> `docs/machines/gatekeeper/tailnet/configs/*`
- [x] `tailnet/scripts/*` -> `docs/machines/gatekeeper/tailnet/scripts/*`
- [x] `tailnet/.github/copilot-instructions.md` -> retired; root `AGENTS.md` is the canonical agent instruction source

### Independent service repos (not folded)

- [x] `/home/siderealyear/llama.cpp` -> kept independent; operational references in `docs/machines/pyrite/services/README.md`
- [x] `/home/siderealyear/postgreSQL-server` -> kept independent; operational references in `docs/machines/pyrite/services/README.md`

## Related historical documents

- [VPS Infrastructure Reorganization Guide](../machines/gatekeeper/docs/IMPLEMENTATION-GUIDE.md) —
  the phased plan that created `vps-infrastructure` (April 2026), now itself consolidated here.
- [Phase 3 Summary](../machines/gatekeeper/docs/phase3-summary.md) — monitoring stack
  separation record (April 2026).
