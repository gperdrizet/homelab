# homelab

[![Publish to GitHub Pages](https://github.com/gperdrizet/homelab/actions/workflows/publish.yml/badge.svg)](https://github.com/gperdrizet/homelab/actions/workflows/publish.yml)

Documentation, configuration, and runbooks for the gperdrizet personal computing infrastructure.

Most content here is intentionally public: setup guides, deployment patterns, and operational
notes that may be useful to others (including AI/ML bootcamp students).

**Secrets are never committed to this repo.** See [docs/secrets/README.md](docs/secrets/README.md) for
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
| [gatekeeper](docs/machines/gatekeeper/) | VPS: public-facing services, reverse proxy, monitoring | Ionos cloud (74.208.107.78) | Active |
| [pyrite](docs/machines/pyrite/)     | Desktop: primary dev and compute machine | Home office    | Active  |
| [arkk](docs/machines/arkk/)       | NAS: RAID storage server, NFS          | Home office    | Active |

## Core services on pyrite

These are the primary services hosted on pyrite for the broader homelab stack.
See [docs/machines/pyrite/services/README.md](docs/machines/pyrite/services/README.md) for full details.

| Service | Port | Access path | Notes |
|---------|------|-------------|-------|
| llama.cpp | 8502 | API access via promptlyapi.com on gatekeeper nginx | Inference backend for model-gateway |
| PostgreSQL | 5432 | Public via gatekeeper TCP stream proxy on 54321 | Primary remote database service |
| nixx | 8000 | Reverse proxied at nixx.perdrizet.org via gatekeeper | Personal assistant and memory system |
| JupyterLab | 47302 | Reverse proxied at jupyter.perdrizet.org via gatekeeper | Containerized remote notebook service on pyrite |

## Network

See [docs/network/](docs/network/) for topology, Tailscale/Headscale config, and the local LAN layout
for current machine connectivity and routing.

## Secrets

See [docs/secrets/](docs/secrets/): Vaultwarden (self-hosted Bitwarden) for passwords and credentials,
`.env.template` pattern for per-project infrastructure secrets.

Status: implemented and in active use.

## Backups

See [docs/backups/](docs/backups/): restic-based backup strategy targeting arkk RAID array.

Status: partially implemented. Existing database backups are running; full restic coverage is still being completed.

## External repos (hosted on this infrastructure)

These repos live on GitHub independently but are documented here as part of the homelab stack:

| Repo | Description |
|------|-------------|
| [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp) | llama.cpp inference server running on pyrite |
| [gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server) | PostgreSQL server on pyrite, exposed via VPS TCP proxy |
| [gperdrizet/nixx](https://github.com/gperdrizet/nixx) | Personal assistant and memory system running on pyrite |
| [gperdrizet/docker-images](https://github.com/gperdrizet/docker-images) | Custom Docker base images used across projects |
