# homelab

[![Publish to GitHub Pages](https://github.com/gperdrizet/homelab/actions/workflows/publish.yml/badge.svg)](https://github.com/gperdrizet/homelab/actions/workflows/publish.yml)

Documentation, configuration, and runbooks for the gperdrizet personal computing infrastructure.

Most content here is intentionally public: setup guides, deployment patterns, and operational
notes that may be useful to others (including AI/ML bootcamp students).

**Secrets are never committed to this repo.** See [secrets/README.md](secrets/README.md) for
how credentials and API keys are managed.

## Documentation site

This repo publishes a static documentation site with MkDocs Material.

- Site config: [mkdocs.yml](mkdocs.yml)
- Docs content: [docs/](docs/)
- Publish workflow: [.github/workflows/publish.yml](.github/workflows/publish.yml)

### Local preview

```bash
pip install mkdocs-material
mkdocs serve
```

### Deployment

Pushing to `main` triggers the publish workflow, which runs `mkdocs gh-deploy --force` and updates the `gh-pages` branch used by GitHub Pages.

---

## Machines

| Machine    | Role                                    | Location       | Status  |
|------------|-----------------------------------------|----------------|---------|
| [gatekeeper](machines/gatekeeper/) | VPS: public-facing services, reverse proxy, monitoring | Ionos cloud (74.208.107.78) | Active |
| [pyrite](machines/pyrite/)     | Desktop: primary dev and compute machine | Home office    | Active  |
| [arkk](machines/arkk/)       | NAS: RAID storage server, NFS          | Home office    | Recovering |

## Core services on pyrite

These are the primary services hosted on pyrite for the broader homelab stack.
See [machines/pyrite/services/README.md](machines/pyrite/services/README.md) for full details.

| Service | Port | Access path | Notes |
|---------|------|-------------|-------|
| llama.cpp | 8502 | Tailscale from gatekeeper | Inference backend for model-gateway |
| PostgreSQL | 5432 | Public via gatekeeper TCP stream proxy on 54321 | Primary remote database service |
| nixx | 8000 | Reverse proxied at nixx.perdrizet.org via gatekeeper | Personal assistant and memory system |

## Network

See [network/](network/) for topology, Tailscale/Headscale config, and the local LAN layout
including the bonded pyrite↔arkk connection.

## Secrets

See [secrets/](secrets/): Vaultwarden (self-hosted Bitwarden) for passwords and credentials,
`.env.template` pattern for per-project infrastructure secrets.

## Backups

See [backups/](backups/): restic-based backup strategy targeting arkk RAID array.

## External repos (hosted on this infrastructure)

These repos live on GitHub independently but are documented here as part of the homelab stack:

| Repo | Description |
|------|-------------|
| [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp) | llama.cpp inference server running on pyrite |
| [gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server) | PostgreSQL server on pyrite, exposed via VPS TCP proxy |
| [gperdrizet/nixx](https://github.com/gperdrizet/nixx) | Personal assistant and memory system running on pyrite |
| [gperdrizet/docker-images](https://github.com/gperdrizet/docker-images) | Custom Docker base images used across projects |
