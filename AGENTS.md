# homelab agent orientation

Quick orientation for coding agents working in this repository.

## Purpose

This repo stores infrastructure docs, configs, and runbooks for a multi-machine homelab:
- gatekeeper: public VPS and ingress plane
- pyrite: workstation and compute plane
- arkk: NAS and storage plane

## Reusable machine documentation model

Each machine directory should follow this structure:

1. README.md
- machine identity, role, network identity, and quick links

2. docs/
- platform-baseline.md: canonical decisions and current posture
- boot-and-startup.md: boot critical path and service ordering
- wayland-and-av.md or equivalent UI/AV notes where relevant
- remote-access.md: SSH, tunnel, and remote control model
- troubleshooting.md: symptom to fix notes
- change-log.md: important machine-level transitions
- TODO.md: open platform tasks

3. services/
- README.md: currently hosted services and ingress model
- TODO.md: service roadmap only (no workstation tuning tasks)

4. guides/
- app or tool install guides specific to that machine

## Repository map

- docs/machines/: machine-specific operational state
- docs/network/: topology and tailnet design
- docs/backups/: backup strategy and scripts
- docs/secrets/: secret handling strategy, templates only in git
- docs/docker-images/: external image dependency notes
- docs/: MkDocs site content for published documentation

## Authoring conventions

1. Single source of truth:
- keep platform internals in machine docs/
- keep service inventory in machine services/

2. Keep secrets out of git:
- commit .env.template files only
- store real credentials in Vaultwarden

3. Prefer tailnet private paths:
- services should be private-by-default
- public ingress should terminate on gatekeeper

4. Document every operational change with:
- decision
- apply steps
- verify steps
- revert path

## Current infrastructure notes

- gatekeeper hosts public nginx ingress and most containerized app stacks
- pyrite hosts core compute and data services consumed via tailnet
- arkk remains the storage target and recovery-in-progress node

## Fast orientation links

- Root overview: README.md
- Gatekeeper service/domain inventory: docs/machines/gatekeeper/docs/services.md
- Gatekeeper infra layout: docs/machines/gatekeeper/docs/infrastructure-layout.md
- Pyrite overview: docs/machines/pyrite/README.md
- Pyrite platform docs: docs/machines/pyrite/docs/

## External repos in this ecosystem

- https://github.com/gperdrizet/llama.cpp
- https://github.com/gperdrizet/postgreSQL-server
- https://github.com/gperdrizet/nixx
- https://github.com/gperdrizet/docker-images
