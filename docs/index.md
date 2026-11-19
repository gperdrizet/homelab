# Homelab documentation

Single source of truth for the machines, network, and services that make up the
homelab. Published from the [gperdrizet/homelab](https://github.com/gperdrizet/homelab) repository.

Docs are organized **service-first**: each running service has a page naming
its host, ports, ingress path, and repo. Machine pages cover hardware, OS, and
platform posture only. Start with the [service inventory](services/README.md).

## The machines

| Machine | Role | Docs |
|---------|------|------|
| [gatekeeper](machines/gatekeeper/README.md) | IONOS VPS: public ingress, TLS, app hosting, monitoring, tailnet control | Active |
| [pyrite](machines/pyrite/README.md) | ML/AI workhorse: inference, LiteLLM router, PostgreSQL, 15 TB storage | Active |
| [ethics-gradient](machines/ethics-gradient/README.md) | Desktop workstation; embedding + light utility inference | Active |
| [the-educator](machines/the-educator/README.md) | Home theater PC; Minecraft server | Active (stub) |
| [hugo](machines/hugo/README.md) | Raspberry Pi 0 W; spare | Active (stub) |

`arkk` (old NAS) was decommissioned; its 15 TB RAID5 now lives in pyrite and is
documented under [pyrite](machines/pyrite/README.md). Historical pages are in
[archive](archive/arkk/README.md).

## Start here

- **Looking for a service?** [Service inventory](services/README.md)
- **How machines connect:** [Network overview](network/README.md)
- **Day-2 operations:** [Operations index](operations.md) — backups, secrets, docker images

## Design principles

- **Private by default** — services live on the tailnet; public ingress terminates
  on gatekeeper only.
- **Secrets stay out of git** — `.env.template` committed, real values in
  Vaultwarden. See [secrets management](secrets/README.md).
- **Docs track current state** — inventory pages describe active infrastructure,
  not migration history.
- **Service pages name their host** — services may move machines; the page
  travels with the service, not the directory.

## Related repositories

| Repo | Contents |
|------|----------|
| [llama.cpp](https://github.com/gperdrizet/llama.cpp) | Inference server containers (pyrite, ethics-gradient) |
| [postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server) | Multi-tenant PostgreSQL on pyrite |
| [nixx](https://github.com/gperdrizet/nixx) | nixx server (currently not deployed) |
| [docker-images](https://github.com/gperdrizet/docker-images) | Custom base images on GHCR |

## Local preview

```bash
pip install mkdocs-material
mkdocs serve
```

Then open `http://127.0.0.1:8000`.
