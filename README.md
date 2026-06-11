# homelab

Documentation, configuration, and runbooks for the gperdrizet personal computing infrastructure.

Most content here is intentionally public — setup guides, deployment patterns, and operational
notes that may be useful to others (including AI/ML bootcamp students).

**Secrets are never committed to this repo.** See [secrets/README.md](secrets/README.md) for
how credentials and API keys are managed.

---

## Machines

| Machine    | Role                                    | Location       | Status  |
|------------|-----------------------------------------|----------------|---------|
| [gatekeeper](machines/gatekeeper/) | VPS — public-facing services, reverse proxy, monitoring | Ionos cloud (74.208.107.78) | Active |
| [pyrite](machines/pyrite/)     | Desktop — primary dev and compute machine | Home office    | Active  |
| [arkk](machines/arkk/)       | NAS — RAID storage server, NFS          | Home office    | Recovering |

## Network

See [network/](network/) for topology, Tailscale/Headscale config, and the local LAN layout
including the bonded pyrite↔arkk connection.

## Secrets

See [secrets/](secrets/) — Vaultwarden (self-hosted Bitwarden) for passwords and credentials,
`.env.template` pattern for per-project infrastructure secrets.

## Backups

See [backups/](backups/) — restic-based backup strategy targeting arkk RAID array.

## External repos (hosted on this infrastructure)

These repos live on GitHub independently but are documented here as part of the homelab stack:

| Repo | Description |
|------|-------------|
| [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp) | llama.cpp inference server running on pyrite |
| [gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server) | PostgreSQL server on pyrite, exposed via VPS TCP proxy |
| [gperdrizet/docker-images](https://github.com/gperdrizet/docker-images) | Custom Docker base images used across projects |
