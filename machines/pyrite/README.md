# pyrite

Primary development and compute workstation in the home office.

---

## Hardware profile

**Platform:** Supermicro X9SRA-3  
**CPU:** Intel Xeon E5-2697 v2 (12-core)  
**RAM:** 251 GB  
**GPU:** NVIDIA GTX 1070 + Tesla P100  
**OS:** Ubuntu 24.04 LTS

**Network:**
- LAN connectivity in home office
- Tailscale client: 100.64.0.2
- NFS client to arkk storage mounts

---

## Role

- Primary developer desktop (VS Code, Zed, Python, Docker)
- GPU compute host for local AI and inference workflows
- Host for core services consumed by gatekeeper over tailnet
- Workstation platform for Wayland desktop and AV tooling

---

## Access model

- Tailscale is the canonical private network path.
- Public ingress terminates on gatekeeper, then proxies to pyrite via 100.64.0.2.
- VS Code tunnel is available for browser-based remote editing.

---

## Core services

| Service | Port | Access path | Notes |
|---------|------|-------------|-------|
| llama.cpp | 8502 | gatekeeper over tailnet | Backend for model-gateway |
| PostgreSQL | 5432 | gatekeeper stream proxy (54321 public) | Remote database access |
| nixx | 8000 | gatekeeper reverse proxy | nixx.perdrizet.org |
| OpenVSCode Server | 47301 | gatekeeper reverse proxy over tailnet | code.perdrizet.org |
| JupyterLab | 47302 | gatekeeper reverse proxy over tailnet | jupyter.perdrizet.org |
| VS Code Tunnel | N/A | vscode.dev/tunnel/pyrite | Outbound remote access path |

Service repo references:
- https://github.com/gperdrizet/llama.cpp
- https://github.com/gperdrizet/postgreSQL-server
- https://github.com/gperdrizet/nixx

---

## Documentation map

- [docs/platform-baseline.md](docs/platform-baseline.md): canonical workstation posture and decisions
- [docs/boot-and-startup.md](docs/boot-and-startup.md): boot-path optimization and service ordering
- [docs/wayland-and-av.md](docs/wayland-and-av.md): Wayland, OBS, Chrome, Zoom behavior
- [docs/remote-access.md](docs/remote-access.md): Tailscale and VS Code tunnel operations
- [docs/troubleshooting.md](docs/troubleshooting.md): known issues and fixes
- [docs/change-log.md](docs/change-log.md): consolidated migration history
- [docs/TODO.md](docs/TODO.md): remaining platform tasks

- [services/](services/): pyrite service inventory and service roadmap
- [guides/](guides/): app and tooling setup guides
