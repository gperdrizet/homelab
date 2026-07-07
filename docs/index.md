# Homelab documentation

Single source of truth for the machines, network, and services that make up the
homelab. Published from the [gperdrizet/homelab](https://github.com/gperdrizet/homelab) repository.

## The machines

| Machine | Role | Status |
|---------|------|--------|
| [gatekeeper](machines/gatekeeper/README.md) | Public VPS: ingress, TLS, monitoring, app hosting | Active |
| [pyrite](machines/pyrite/README.md) | Workstation: development, GPU compute, core services | Active |
| [arkk](machines/arkk/README.md) | NAS: RAID storage, backup target | Active |
| [the-educator](machines/the-educator/README.md) | Home theater, gaming, minecraft server | Active |

## Start here

- **Looking for a service?** [Gatekeeper service and port inventory](machines/gatekeeper/docs/services.md)
  and [services on pyrite](machines/pyrite/services/README.md)
- **How machines connect:** [Network overview](network/README.md)
- **Day-2 operations:** [Operations index](operations.md) — backups, secrets, docker images
- **Active incident:** [arkk RAID recovery](machines/arkk/RAID_RECOVERY_2026.md) and
  [backup triage](machines/arkk/BACKUP_TRIAGE_2026.md)

## Design principles

- **Private by default** — services live on the tailnet; public ingress terminates
  on gatekeeper only.
- **Secrets stay out of git** — `.env.template` committed, real values in
  Vaultwarden. See [secrets management](secrets/README.md).
- **Every operational change documents** decision, apply steps, verify steps,
  and revert path.

## Related repositories

| Repo | Contents |
|------|----------|
| [llama.cpp](https://github.com/gperdrizet/llama.cpp) | Inference server on pyrite (port 8502) |
| [postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server) | Multi-tenant PostgreSQL on pyrite |
| [nixx](https://github.com/gperdrizet/nixx) | nixx server on pyrite (port 8000) |
| [docker-images](https://github.com/gperdrizet/docker-images) | Custom base images on GHCR |

## Local preview

```bash
pip install mkdocs-material
mkdocs serve
```

Then open `http://127.0.0.1:8000`.
