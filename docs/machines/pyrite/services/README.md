# Services on pyrite

This page documents the services running on pyrite that are accessible from
the rest of the homelab. Each service is maintained in its own repo.

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

---

## llama.cpp inference server

**Repo:** [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp)  
**Bind:** `0.0.0.0:8502` (consumed by gatekeeper over tailnet at `100.64.0.2:8502`)  
**Model:** `/opt/models/gpt-oss-20b-mxfp4.gguf`  
**GPU:** Tesla P100 (`CUDA_VISIBLE_DEVICES=0`)  
**Backend for:** model-gateway (promptlyapi.com, model.perdrizet.org)

Operational references:
- systemd unit: `llamacpp.service` (binary `/opt/llama.cpp/build/bin/llama-server`)
- Waits for the GPU before start (`ExecStartPre` polls `nvidia-smi`)
- Health endpoint: `http://100.64.0.2:8502/health`
- Logs: `journalctl -u llamacpp.service -f`
- Public access is mediated by gatekeeper/model-gateway; not directly exposed.

---

## PostgreSQL server

**Repo:** [gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server)  
**Container:** `student-postgres` (`pgvector/pgvector:pg16`, PostgreSQL 16.13)  
**Bind:** `0.0.0.0:5432` (local) → `:54321` public via gatekeeper nginx TCP stream proxy  
**Used by:** external clients connecting to pyrite's database over the internet

Operational references:
- Compose source: `docker-compose.yml` in the postgreSQL-server repo
- Auth/TLS config: `config/pg_hba.conf`, `config/postgresql.conf`
- Admin surface: `make help` in the repo
- Metrics: `postgres-exporter` container on pyrite (`:9187`), scraped by monitoring
- Gatekeeper owns the public stream proxy (`:54321` → `100.64.0.2:5432`)

---

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

---

## model-gateway

**Bind:** `0.0.0.0:8503` (container `model-gateway-gateway-1`, healthy)  
Runs on pyrite in front of llama.cpp; also mirrored on gatekeeper for public
ingress (model.perdrizet.org / promptlyapi.com). Adminer companion on
`127.0.0.1:8504`.

---

## Developer endpoints (tailnet-only)

These bind to pyrite's Tailscale IP `100.64.0.2` and are proxied by gatekeeper:

| Service | Bind | Ingress | systemd unit |
|---------|------|---------|--------------|
| OpenVSCode Server | `100.64.0.2:47301` | code.perdrizet.org | `openvscode-server` |
| JupyterLab | `100.64.0.2:47302` | jupyter.perdrizet.org | `jupyterlab` |
| VS Code Tunnel | Microsoft relay | vscode.dev/tunnel | `vscode-tunnel` |

> Because these bind the tailnet IP, they are unreachable whenever Tailscale is
> down on pyrite — see the gatekeeper [incidents](../../gatekeeper/docs/incidents.md) note.

---

## Access and ingress model

- pyrite services are consumed privately over tailnet by gatekeeper.
- Public TLS termination and external domain routing happen on gatekeeper nginx.
- Legacy autossh and WireGuard tunnels are retired for pyrite service ingress.

---

## Docker images

**Repo:** [gperdrizet/docker-images](https://github.com/gperdrizet/docker-images)  
Custom Docker base images built and pushed to GHCR, used across projects on
both pyrite and gatekeeper.
