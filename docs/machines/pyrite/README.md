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

| Service | Bind | Ingress path | Status |
|---------|------|--------------|--------|
| llama.cpp | `0.0.0.0:8502` | gatekeeper over tailnet | active (systemd) |
| model-gateway | `0.0.0.0:8503` | model.perdrizet.org / promptlyapi.com | active (docker) |
| PostgreSQL (postgreSQL-server) | `0.0.0.0:5432` | gatekeeper stream proxy `:54321` | active (docker) |
| nixx | `100.64.0.2:8000` | nixx.perdrizet.org | enabled, **inactive** |
| OpenVSCode Server | `100.64.0.2:47301` | code.perdrizet.org | active (systemd) |
| JupyterLab | `100.64.0.2:47302` | jupyter.perdrizet.org | active (systemd) |
| VS Code Tunnel | Microsoft relay | vscode.dev/tunnel/pyrite | active (systemd) |
| Grafana / Prometheus / postgres-exporter | `:3000` / `:9090` / `:9187` | local monitoring | active (docker) |

See [services/README.md](services/README.md) for per-service detail (ports,
units, models, dependencies).

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

- [services/README.md](services/README.md): pyrite service inventory; roadmap in [services/TODO.md](services/TODO.md)
- `guides/`: app and tooling setup guides —
  [OBS audio](guides/obs-audio.md), [OBS video](guides/obs-video.md),
  [Zed install](guides/zed-install.md),
  [Google Cloud remote dev](guides/google-cloud-remote-dev.md),
  [ML workstation build plan](guides/ml-workstation-build-plan.md)
- [guides/obs-audio.md](guides/obs-audio.md): OBS virtual microphone, audio routing, and filter chain
- [guides/obs-video.md](guides/obs-video.md): OBS video capture, NVENC tuning, and plugin notes
- [guides/ml-workstation-build-plan.md](guides/ml-workstation-build-plan.md): future workstation hardware planning reference
- [guides/google-cloud-remote-dev.md](guides/google-cloud-remote-dev.md): optional VS Code remote workflow for Google Cloud VMs
