# Operations

## Machine operations entry points

### arkk (NAS, RAID recovery priority)

- [machine overview](machines/arkk/README.md)
- [RAID recovery runbook (general)](machines/arkk/RAID_RECOVERY.md)
- [RAID recovery incident notes (2026)](machines/arkk/RAID_RECOVERY_2026.md)
- [backup triage notes (2026)](machines/arkk/BACKUP_TRIAGE_2026.md)

### gatekeeper (VPS ingress and public services)

- [machine overview](machines/gatekeeper/README.md)
- [service and port inventory](machines/gatekeeper/docs/services.md)
- [infrastructure layout](machines/gatekeeper/docs/infrastructure-layout.md)
- [backup improvement notes](machines/gatekeeper/docs/backup-improvements.md)

### pyrite (workstation and backup target host)

- [machine overview](machines/pyrite/README.md)
- [platform baseline](machines/pyrite/docs/platform-baseline.md)
- [boot and startup](machines/pyrite/docs/boot-and-startup.md)
- [remote access](machines/pyrite/docs/remote-access.md)
- [services on pyrite](machines/pyrite/services/README.md)

## Cross-cutting operations

- [backups strategy](backups/README.md)
- [network documentation](network/README.md)
- [secrets management](secrets/README.md)
- [docker images](docker-images/README.md)

## Consolidation scope and ownership

- `/home/siderealyear/admin/`:
	migrate durable runbooks and machine/service/network notes into this repo, then retire admin docs.
- `/home/siderealyear/vps-infrastructure/`:
	migrate gatekeeper infrastructure docs and operational notes into this repo, then retire external VPS infra docs.
- `/home/siderealyear/llama.cpp/`:
	remains an independent service repo. Homelab docs track deployment topology, ingress path, dependencies, backup, and incident behavior.
- `/home/siderealyear/postgreSQL-server/`:
	remains an independent service repo. Homelab docs track deployment topology, ingress path, dependencies, backup, and incident behavior.

Secrets are excluded from documentation migration. Secret values remain outside git and are managed per [secrets management](secrets/README.md).

## Consolidation priority

1. Complete arkk RAID recovery and backup triage documentation.
2. Consolidate gatekeeper VPS operational docs.
3. Consolidate pyrite workstation/AV setup notes not yet represented here.
4. Keep llama.cpp and PostgreSQL app-level docs in their own repos while maintaining infra-level operational references here.

## File-by-file migration checklist

### admin -> homelab

- [x] `arkk-backup-list.md` -> `docs/machines/arkk/BACKUP_TRIAGE_2026.md`
- [x] `system-setup/boot-optimization.md` -> consolidated into `docs/machines/pyrite/docs/boot-and-startup.md`
- [x] `system-setup/system-tuning.md` -> consolidated into `docs/machines/pyrite/docs/platform-baseline.md` and `docs/machines/pyrite/docs/troubleshooting.md`
- [x] `system-setup/vscode-tunnel.md` -> consolidated into `docs/machines/pyrite/docs/remote-access.md`
- [x] `system-setup/wayland-switchover.md` -> consolidated into `docs/machines/pyrite/docs/wayland-and-av.md`
- [x] `system-setup/TODO.md` -> consolidated into `docs/machines/pyrite/docs/TODO.md`
- [ ] `obs-audio.md` -> target `docs/machines/pyrite/guides/` (pending migration)
- [ ] `obs-video.md` -> target `docs/machines/pyrite/guides/` (pending migration)
- [ ] `new-machine-build-plan.md` -> target scope decision pending (likely `docs/machines/pyrite/guides/` or top-level planning doc)
- [ ] `vscode-google-cloud-setup-notes.md` -> target scope decision pending (remote-cloud workflow guide location)
- [ ] `wish-list.md` -> target scope decision pending (platform backlog vs personal backlog)
- [ ] `secrets/*` -> excluded from git docs migration; track only in `docs/secrets/README.md` policy

### vps-infrastructure -> homelab

- [ ] `README.md` -> partially represented in `docs/machines/gatekeeper/README.md`; remaining legacy quickstart/maintenance blocks should be trimmed or split into canonical runbooks
- [x] `docs/services.md` -> represented in `docs/machines/gatekeeper/docs/services.md`
- [x] `docs/infrastructure-layout.md` -> represented in `docs/machines/gatekeeper/docs/infrastructure-layout.md`
- [x] `docs/backup-improvements.md` -> represented in `docs/machines/gatekeeper/docs/backup-improvements.md`
- [x] `docs/IMPLEMENTATION-GUIDE.md` -> represented in `docs/machines/gatekeeper/docs/IMPLEMENTATION-GUIDE.md`
- [x] `docs/phase3-summary.md` -> represented in `docs/machines/gatekeeper/docs/phase3-summary.md`
- [x] `docker-compose.core.yml` -> `docs/machines/gatekeeper/docker-compose.core.yml`
- [x] `docker-compose.monitoring.yml` -> `docs/machines/gatekeeper/docker-compose.monitoring.yml`
- [x] `compose/*` -> `docs/machines/gatekeeper/compose/*`
- [x] `configs/*` -> `docs/machines/gatekeeper/configs/*`
- [x] `scripts/*` -> `docs/machines/gatekeeper/scripts/*`
- [x] `tailnet/README.md` -> `docs/machines/gatekeeper/tailnet/README.md`
- [x] `tailnet/docs/manual-steps.md` -> `docs/machines/gatekeeper/tailnet/docs/manual-steps.md`
- [x] `tailnet/configs/*` -> `docs/machines/gatekeeper/tailnet/configs/*`
- [x] `tailnet/scripts/*` -> `docs/machines/gatekeeper/tailnet/scripts/*`
- [ ] `tailnet/.github/copilot-instructions.md` -> evaluate whether to fold into root repo instructions or retire

### Independent service repos (not folded)

- [ ] `/home/siderealyear/llama.cpp` -> keep independent; ensure homelab docs stay current for deployment topology and operations
- [ ] `/home/siderealyear/postgreSQL-server` -> keep independent; ensure homelab docs stay current for deployment topology and operations
