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
| [gatekeeper](docs/machines/gatekeeper/) | VPS: public-facing services, reverse proxy, monitoring, tailnet control | Ionos cloud (74.208.107.78) | Active |
| [pyrite](docs/machines/pyrite/)     | ML/AI workhorse: inference, router, PostgreSQL, 15 TB storage | Home office    | Active  |
| [ethics-gradient](docs/machines/ethics-gradient/) | Desktop workstation; utility/embedding inference | Home office    | Active |
| [the-educator](docs/machines/the-educator/) | HTPC, Minecraft server | Home | Active |
| [hugo](docs/machines/hugo/) | Raspberry Pi 0 W, spare | Home | Active |

`arkk` (old NAS) is decommissioned; its RAID array now runs inside pyrite.
Historical docs: [docs/archive/arkk/](docs/archive/arkk/README.md).

## Services

The full cross-host service inventory is in
[docs/services/](docs/services/README.md). Headlines:

| Service | Host | Access path |
|---------|------|-------------|
| Promptly API | gatekeeper | promptlyapi.com → LiteLLM router (pyrite `:8502`) → llama.cpp containers |
| PostgreSQL | pyrite | tailnet `:5432`; public via gatekeeper TCP stream proxy `:54321` |
| JupyterLab | pyrite | jupyter.perdrizet.org → `100.64.0.2:47302` |
| Web apps (logkeep, bench, bug-hunter, feedback) | gatekeeper | `*.perdrizet.org` |

## Network

See [docs/network/](docs/network/) for topology, Tailscale/Headscale config, and the local LAN layout
for current machine connectivity and routing.

## Secrets

See [docs/secrets/](docs/secrets/): Vaultwarden (self-hosted Bitwarden) for passwords and credentials,
`.env.template` pattern for per-project infrastructure secrets.

Status: implemented and in active use.

## Backups

See [docs/backups/](docs/backups/): restic-based backup strategy targeting the
15 TB array (now local to pyrite — offsite coverage is the open gap).

Status: partially implemented. Existing database backups are running; full restic coverage is still being completed.

## External repos (hosted on this infrastructure)

These repos live on GitHub independently but are documented here as part of the homelab stack:

| Repo | Description |
|------|-------------|
| [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp) | llama.cpp inference server running on pyrite |
| [gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server) | PostgreSQL server on pyrite, exposed via VPS TCP proxy |
| [gperdrizet/nixx](https://github.com/gperdrizet/nixx) | Personal assistant and memory system running on pyrite |
| [gperdrizet/docker-images](https://github.com/gperdrizet/docker-images) | Custom Docker base images used across projects |
