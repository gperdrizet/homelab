# homelab agent orientation

Quick orientation for coding agents working in this repository.

## Purpose

This repo stores infrastructure docs, configs, and runbooks for a
multi-machine homelab:

- **gatekeeper**: IONOS VPS — public ingress, app hosting, monitoring, Headscale
- **pyrite**: ML/AI workhorse — llama.cpp + LiteLLM router, PostgreSQL, 15 TB storage
- **ethics-gradient**: desktop workstation — utility/embedding inference
- **the-educator**: HTPC + Minecraft server
- **hugo**: RPi 0 W spare

`arkk` (old NAS) is decommissioned → `docs/archive/arkk/`. Its RAID array is
now local to pyrite.

## Structure (service-first)

Docs are organized so a service page travels with the service, not the machine:

1. `docs/services/` — one page per service (host, ports, ingress, repo,
   dependencies). `services/README.md` is the master inventory; keep it first.
2. `docs/machines/<host>/README.md` — hardware, OS, network identity, role.
   Machine pages link to service pages instead of restating ports/paths.
3. `docs/machines/<host>/docs|guides/` — platform posture, runbooks, guides.
4. `docs/network/` — LAN, tailnet, NFS.
5. `docs/operations/`, `docs/backups/`, `docs/secrets/`, `docs/docker-images/`
   — cross-cutting concerns.
6. `docs/machines/gatekeeper/{configs,compose,scripts}/` — live-file mirrors
   (nginx, monitoring, compose). This pattern kept gatekeeper docs honest —
   prefer mirroring real files over hand-maintained prose.
7. `docs/archive/` — decommissioned hardware; banner-marked, not in nav.

`mkdocs.yml` nav must list every non-archived page (avoid orphan warnings).

## Authoring conventions

1. **Verified-date stamp**: audit pages against live state and note the date.
2. **Single source per fact**: ports/ingress only on the service page;
   hardware only on the machine page.
3. **Keep secrets out of git**: commit `.env.template` files only; real values
   live in Vaultwarden.
4. **Prefer tailnet private paths**: services bind tailnet/localhost; public
   ingress terminates on gatekeeper only.
5. **Document operational changes** with: decision, apply steps, verify steps,
   revert path.
6. **Stub honestly**: a short page marked "stub — TODO" beats a long stale one.

## Current infrastructure notes

- Inference chain: promptlyapi.com → gatekeeper nginx → model-gateway-api
  (`:8503`) → LiteLLM router (pyrite `:8502`) → llama-cuda containers on
  pyrite (bridge network, no host port) and ethics-gradient (`:8080`).
- NFS: pyrite exports `/mnt/arkk` (the old arkk RAID) to the LAN.
- Headscale (gatekeeper) is the tailnet control plane; `tailscale status` on
  any enrolled machine is the live device list.

## Fast orientation links

- Site home: `docs/index.md`
- Service inventory: `docs/services/README.md`
- Machine overview: `docs/machines.md`
- Gatekeeper deploy layout: `docs/machines/gatekeeper/docs/infrastructure-layout.md`

## External repos in this ecosystem

- https://github.com/gperdrizet/llama.cpp
- https://github.com/gperdrizet/postgreSQL-server
- https://github.com/gperdrizet/nixx
- https://github.com/gperdrizet/docker-images
