# Services on pyrite

This page documents the services running on pyrite that are accessible from
the rest of the homelab. Most services are maintained in separate repos.

The JupyterLab deployment for pyrite is intentionally maintained in this
homelab repo under `services/jupyterlab/` because it is infrastructure wiring
for this specific host and ingress path.

Planned additions and infrastructure follow-up tasks are tracked in
[TODO.md](TODO.md).

Platform-level workstation setup and tuning notes are tracked in
https://github.com/gperdrizet/homelab/tree/main/docs/machines/pyrite/docs.


## Documentation boundary

- Homelab docs are the infrastructure source of truth: host placement, bind
	addresses, ingress paths, backup expectations, dependencies, and incident
	operations.
- Service repos are the application source of truth: implementation details,
	API behavior, migrations, and release/version specifics.

For services that remain independent repos (including llama.cpp and
postgreSQL-server), this page and related machine docs must always document the
current homelab deployment path and operational dependencies.


## llama.cpp inference server

**Repo:** [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp)  
**Bind:** `0.0.0.0:8502` (consumed by gatekeeper over tailnet at `100.64.0.2:8502`)  
**Model:** `/opt/models/gpt-oss-20b-mxfp4.gguf`  
**GPU:** Tesla P100 (`CUDA_VISIBLE_DEVICES=0`)  
**Backend for:** Promptly API on gatekeeper (promptlyapi.com)

Operational references:
- systemd unit: `llamacpp.service` (binary `/opt/llama.cpp/build/bin/llama-server`)
- Waits for the GPU before start (`ExecStartPre` polls `nvidia-smi`)
- Health endpoint: `http://100.64.0.2:8502/health`
- Logs: `journalctl -u llamacpp.service -f`
- Public access is mediated by gatekeeper/Promptly; not directly exposed.


## PostgreSQL server

**Repo:** [gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server)  
**Container:** `student-postgres` (`pgvector/pgvector:pg16`, PostgreSQL 16.13)  
**Bind:** `0.0.0.0:5432` (local) → `:54321` public via gatekeeper nginx TCP stream proxy  
**Used by:** external clients connecting to pyrite's database over the internet

Operational references:
- Compose source: `docker-compose.yml` in the postgreSQL-server repo
- Auth/TLS config: `config/pg_hba.conf`, `config/postgresql.conf`
- Admin surface: `make help` in the repo
- Metrics: `postgres-exporter` container on pyrite (`:9187`), scraped by gatekeeper Prometheus over tailnet
- Gatekeeper owns the public stream proxy (`:54321` → `100.64.0.2:5432`)


## nixx

**Repo:** [gperdrizet/nixx](https://github.com/gperdrizet/nixx)  
**Ingress:** nixx.perdrizet.org → gatekeeper → `100.64.0.2:8000` over tailnet  
**Status:** enabled but currently **inactive** (not running as of this writing)

nixx runs as a set of systemd units (grouped under `nixx.target`):

| Unit | Role | Port |
|------|------|------|
| `nixx-server` | API server (`nixx serve`) | 8000 |
| `nixx-admin` | admin dashboard | — |
| `nixx-embed` | embedding server (llama.cpp `llama-server`) | 8082 |
| `nixx-pgweb` | pgweb database browser (`0.0.0.0:8081`) | 8081 |
| `nixx-image` | image generation (FLUX.1 Kontext); **disabled** | — |

Working directory `/home/siderealyear/nixx`. Manage with
`systemctl start nixx.target`; check with `systemctl is-active nixx-server`.


## JupyterLab

**Image:** `gperdrizet/datascience-nvidia:6.0.1`  
**Bind:** `100.64.0.2:47302`  
**Ingress:** jupyter.perdrizet.org -> gatekeeper nginx -> `100.64.0.2:47302`  
**GPU:** Tesla P100 only (`nvidia.com/gpu=0`)  
**Workspace mount:** host home directory mounted at `/workspace`

Operational references:
- Compose source: [jupyterlab/docker-compose.yml](jupyterlab/docker-compose.yml)
- Environment template: [jupyterlab/.env.template](jupyterlab/.env.template)
- Jupyter server config: [jupyterlab/jupyter_server_config.py](jupyterlab/jupyter_server_config.py)
- JupyterLab theme defaults: [jupyterlab/lab/settings/overrides.json](jupyterlab/lab/settings/overrides.json)
- User theme settings: [jupyterlab/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings](jupyterlab/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings)
- systemd unit template: [jupyterlab/jupyterlab.service](jupyterlab/jupyterlab.service)
- Deployment helper script: [../../gatekeeper/tailnet/scripts/setup-dev-server.sh](../../gatekeeper/tailnet/scripts/setup-dev-server.sh)

Authentication note:
- `JUPYTER_PASSWORD_HASH` must be set in `.env` with single quotes preserved,
  e.g. `JUPYTER_PASSWORD_HASH='argon2:...'`.

Availability note:
- JupyterLab binds to pyrite's tailnet IP (`100.64.0.2`), so it is unavailable
	if Tailscale is down on pyrite.


## Access and ingress model

- pyrite services are consumed privately over tailnet by gatekeeper.
- Public TLS termination and external domain routing happen on gatekeeper nginx.
- Legacy autossh and WireGuard tunnels are retired for pyrite service ingress.


## Docker images

**Repo:** [gperdrizet/docker-images](https://github.com/gperdrizet/docker-images)  
Custom Docker base images built and pushed to GHCR, used across projects on
both pyrite and gatekeeper.
