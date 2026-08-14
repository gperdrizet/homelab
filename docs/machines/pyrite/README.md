# pyrite

Primary development and compute workstation in the home office.


## Hardware profile

**Platform:** Supermicro X9SRA-3  
**CPU:** Intel Xeon E5-2697 v2 (12-core)  
**RAM:** 256 GB  
**GPU:** NVIDIA GTX 1070 + Tesla P100 16 GB
**Storage:** 3.7 GB RAID0 + 1 TB NVMe SSD bcache device  
**OS:** Ubuntu 24.04 LTS

**Network:**
- LAN connectivity in home office
- Tailscale client: 100.64.0.2
- Direct link NFS client to arkk RAID


## Role

- Primary developer desktop (VS Code, Zed, Python, Docker)
- GPU compute host for local AI and inference workflows
- Host for core services consumed by gatekeeper over tailnet


## Access model

- Tailscale is the canonical private network path.
- Public ingress terminates on gatekeeper, then proxies to pyrite via 100.64.0.2.


## Core services

| Service | Bind | Ingress path | Status |
|---------|------|--------------|--------|
| llama.cpp | `0.0.0.0:8502` | promptlyapi.com via gatekeeper API | active (systemd) |
| PostgreSQL (postgreSQL-server) | `0.0.0.0:5432` | gatekeeper stream proxy `:54321` | degraded (container restart loop observed) |
| nixx | `100.64.0.2:8000` | nixx.perdrizet.org | enabled, **inactive** |
| JupyterLab | `100.64.0.2:47302` | jupyter.perdrizet.org | active (docker + systemd, image `gperdrizet/datascience-nvidia:6.0.1`) |
| postgres-exporter | `:9187` | scraped by gatekeeper Prometheus over tailnet | active (docker) |

See [services/README.md](services/README.md) for per-service detail (ports,
units, models, dependencies).

Monitoring scope: pyrite exports PostgreSQL metrics via `postgres-exporter`
on `:9187`. Central dashboards, alerting, and long-term metric storage are
hosted on gatekeeper.

Service repo references:
- https://github.com/gperdrizet/llama.cpp
- https://github.com/gperdrizet/postgreSQL-server
- https://github.com/gperdrizet/nixx


## Documentation map

### Platform docs

- [docs/platform-baseline.md](docs/platform-baseline.md): canonical workstation posture and decisions
- [docs/boot-and-startup.md](docs/boot-and-startup.md): boot-path optimization and service ordering
- [docs/remote-access.md](docs/remote-access.md): Tailscale and remote access operations
- [docs/troubleshooting.md](docs/troubleshooting.md): known issues and fixes
- [docs/TODO.md](docs/TODO.md): remaining platform tasks

### Service docs

- [services/README.md](services/README.md): pyrite service inventory
- [services/TODO.md](services/TODO.md): service roadmap and follow-up tasks

### Workstation and media guides

- [docs/wayland-and-av.md](docs/wayland-and-av.md): Wayland, OBS, Chrome, Zoom behavior
- [guides/obs-audio.md](guides/obs-audio.md): OBS virtual microphone, audio routing, and filter chain
- [guides/obs-video.md](guides/obs-video.md): OBS video capture, NVENC tuning, and plugin notes

### Build and development guides

- [guides/zed-install.md](guides/zed-install.md): Zed editor setup notes
- [guides/google-cloud-remote-dev.md](guides/google-cloud-remote-dev.md): optional VS Code remote workflow for Google Cloud VMs
- [guides/ml-workstation-build-plan.md](guides/ml-workstation-build-plan.md): future workstation hardware planning reference
