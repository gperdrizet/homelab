# pyrite

ML/AI workhorse and core services host, in the home office. Audited live
2026-11-18.

## Hardware profile

**Platform:** Supermicro X9SRA-3  
**CPU:** Intel Xeon E5-2697 v2 (12c/24t)  
**RAM:** 256 GB  
**GPU:** 2× Tesla P100 16 GB (the old GTX 1070 now lives in ethics-gradient)  
**Storage:**

| Device | Size | Mount | Notes |
|--------|------|-------|-------|
| `/dev/sde2` (ext4) | 440 GB | `/` | root — **91–93 % full, watch this** |
| `/dev/bcache0` | 2.7 TB | `/mnt/fast_scratch` | NVMe-cached scratch; llama models at `llama-models/`. See [bcache guide](guides/bcache.md) |
| `/dev/md127` (RAID5, xfs) | 15 TB | `/mnt/arkk` | array formerly in `arkk`, now local; exported over NFS |

**OS:** Ubuntu 24.04 LTS

## Network

- LAN: `10.1.10.200` (static)
- Tailscale: `100.64.0.2` — canonical private service address
- NFS **server** for `/mnt/arkk` (clients: hugo, formerly arkk-plane)

## Role

- Primary inference host: llama.cpp container + **LiteLLM router** on `:8502`
  → [inference service page](../../services/inference.md)
- Multi-tenant PostgreSQL — [postgres](../../services/postgres.md)
- JupyterLab — [jupyterlab](../../services/jupyterlab.md)
- Lab-internal Prometheus + Grafana — [monitoring](../../services/monitoring.md)
- OpenClaw gateway + caddy (`openclaw.perdrizet.org`)
- Long-running hobby dashboards (`jobsearch-dashboard` :8790, `jobapp` VNC :6080)
  — tailnet only, stub-level docs
- Storage plane for the fleet (15 TB RAID5 + fast_scratch)

## Access model

- Tailscale is the canonical private path; public ingress terminates on
  gatekeeper and proxies to `100.64.0.2`.
- Most service containers deliberately bind `100.64.0.2` (tailnet-only).
  LiteLLM binds `0.0.0.0:8502` on purpose (LAN + tailnet); the main llama-cuda
  container publishes **no** host port.

## Operational notes

- Root disk is chronically tight (~93 %): prune docker images/build cache
  regularly; models belong on `/mnt/fast_scratch`.
- `tailscale`, `caddy`, `docker`, `nvidia-persistenced`, NFS stack run as
  systemd services; `actions.runner.gperdrizet-docker-images` registers this
  host as a GitHub Actions runner for the docker-images repo.

## Documentation map

### Platform docs

- [docs/platform-baseline.md](docs/platform-baseline.md): canonical workstation posture and decisions
- [docs/boot-and-startup.md](docs/boot-and-startup.md): boot-path optimization and service ordering
- [docs/remote-access.md](docs/remote-access.md): Tailscale and remote access operations
- [docs/troubleshooting.md](docs/troubleshooting.md): known issues and fixes
- [docs/TODO.md](docs/TODO.md): remaining platform tasks

### Workstation and media guides

- [docs/wayland-and-av.md](docs/wayland-and-av.md): Wayland, OBS, Chrome, Zoom behavior
- [guides/obs-audio.md](guides/obs-audio.md): OBS virtual microphone, audio routing, and filter chain
- [guides/obs-video.md](guides/obs-video.md): OBS video capture, NVENC tuning, and plugin notes
- [guides/bcache.md](guides/bcache.md): bcache setup and maintenance
- [guides/zed-install.md](guides/zed-install.md): Zed editor setup notes
- [guides/google-cloud-remote-dev.md](guides/google-cloud-remote-dev.md): optional VS Code remote workflow for Google Cloud VMs
- [guides/ml-workstation-build-plan.md](guides/ml-workstation-build-plan.md): future workstation hardware planning reference

### JupyterLab deployment files

- [services/jupyterlab/](services/jupyterlab/README.md) — compose + systemd + server config (infrastructure wiring kept here on purpose)
