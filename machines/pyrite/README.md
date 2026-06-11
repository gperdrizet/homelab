# pyrite

Primary development and compute machine, physically located in the home office.

---

## Hardware

<!-- TODO: fill in actual specs -->
**Form factor:** Desktop  
**CPU:** <!-- e.g. AMD Ryzen 9 5900X -->  
**RAM:** <!-- e.g. 64 GB DDR4 -->  
**GPU:** <!-- e.g. NVIDIA RTX 3090 -->  
**Storage:**
- <!-- OS drive, e.g. 1TB NVMe SSD -->
- <!-- Data drive(s) -->

**OS:** Ubuntu (LTS)  
**Network:** 
- LAN (gigabit Ethernet to router)
- Direct bonded link to arkk (NFS storage)
- Tailscale client (100.64.0.2)

---

## Role

- Primary development machine: VS Code, Zed, Python, Docker
- Compute: GPU workloads, AI/ML training and inference
- Runs llama.cpp inference server (port 8502): backend for model-gateway on gatekeeper
- Runs PostgreSQL server (port 5432): exposed via gatekeeper TCP proxy on port 54321
- Runs nixx server (port 8000): proxied by gatekeeper at nixx.perdrizet.org
- Reverse tunnel to gatekeeper: exposes OpenVSCode Server (47301) and JupyterLab (47302)
- NFS client to arkk RAID array

---

## Services

| Service | Port | Notes |
|---------|------|-------|
| llama.cpp | 8502 | LLM inference, Tailscale-accessible from gatekeeper |
| PostgreSQL | 5432 | Exposed via gatekeeper TCP proxy (public port 54321) |
| nixx | 8000 | Personal assistant/memory system proxied via nixx.perdrizet.org |
| OpenVSCode Server | 47301 | Tunneled to gatekeeper via autossh, proxied at code.perdrizet.org |
| JupyterLab | 47302 | Tunneled to gatekeeper via autossh, proxied at jupyter.perdrizet.org |
| VS Code Tunnel | N/A | Outbound relay to vscode.dev/tunnel/pyrite (full marketplace + Copilot) |

For a top-level summary of core pyrite-hosted services, see [../../README.md#core-services-on-pyrite](../../README.md#core-services-on-pyrite).

See [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp) and
[gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server), and
[gperdrizet/nixx](https://github.com/gperdrizet/nixx) for those service repos.

---

## Contents

- [guides/](guides/): Install and setup guides for tools on this machine
- [services/](services/): Notes on services running here
