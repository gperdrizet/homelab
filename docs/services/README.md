# Service inventory

Every running service, its host, ports, and ingress path. Audited against live
containers/units on **2026-11-20**. Each service has its own page; stub pages
are marked.

## Public services (ingress on gatekeeper nginx)

| Service | Page | Host | Backend | Public endpoint |
|---------|------|------|---------|-----------------|
| Promptly API (model gateway) | [promptly-api](promptly-api.md) | gatekeeper | `127.0.0.1:8503` | promptlyapi.com, model.perdrizet.org (redirect) |
| LogKeep | [web-apps](web-apps.md) | gatekeeper | `127.0.0.1:8000` | logkeep.perdrizet.org |
| Bench (prod + staging) | [web-apps](web-apps.md) | gatekeeper | `127.0.0.1:8010` / `:8011` | bench.perdrizet.org (bench staging: tailnet-only `100.64.0.1:8012`) |
| Bug Hunter (prod + staging) | [web-apps](web-apps.md) | gatekeeper | `127.0.0.1:8509` | bug-hunter.perdrizet.org |
| Feedback | [web-apps](web-apps.md) | gatekeeper | `127.0.0.1:18080` | feedback.perdrizet.org |
| perdrizet.org site (static) | [web-apps](web-apps.md) | gatekeeper | nginx static root `/opt/perdrizet.org` | perdrizet.org (`www` → apex) |
| perdrizet.org admin panel | [web-apps](web-apps.md) | gatekeeper | `perdrizet-admin.service` `127.0.0.1:8600` | admin.perdrizet.org |
| Grafana | [monitoring](monitoring.md) | gatekeeper | `127.0.0.1:3000` | grafana.perdrizet.org |
| Headscale / Headplane | [headscale](headscale.md) | gatekeeper | `:8090` / `127.0.0.1:3001` | headscale.perdrizet.org, headplane.perdrizet.org |
| JupyterLab | [jupyterlab](jupyterlab.md) | pyrite | `100.64.0.2:47302` | jupyter.perdrizet.org |
| OpenClaw gateway | (machine: pyrite) | pyrite | caddy `:18789` | openclaw.perdrizet.org (DNS-01 TLS via caddy) |

## Tailnet-only services

| Service | Page | Host | Bind |
|---------|------|------|------|
| LiteLLM router | [inference](inference.md) | pyrite | `0.0.0.0:8502` |
| llama.cpp inference (main) | [inference](inference.md) | pyrite | `llama-cuda` container, `llm-network` only (no host port) |
| llama.cpp inference (utility) | [inference](inference.md) | ethics-gradient | `0.0.0.0:8080` |
| PostgreSQL + pgAdmin | [postgres](postgres.md) | pyrite | `100.64.0.2:5432`, pgAdmin `100.64.0.2:8088` |
| Jobsearch dashboard | (stub) | pyrite | `100.64.0.2:8790` |
| Jobapp (VNC) | (stub) | pyrite | `100.64.0.2:6080` |
| NFS server `/mnt/arkk` | [nfs](../network/nfs.md) | pyrite | LAN `10.1.10.0/24` |
| Minecraft (PaperMC) | [minecraft](minecraft.md) | the-educator | `:25565` |

## Not currently deployed

- **nixx** — nginx config `nixx.conf` still present on gatekeeper (proxies
  `100.64.0.2:8000/8001`); no backend running on pyrite (verified dead
  2026-11-20).
- **code.perdrizet.org** — vhost present on gatekeeper nginx proxying
  `100.64.0.2:47301` (legacy OpenVSCode path); nothing listens on pyrite:47301.
- **LogKeep staging** — `staging.perdrizet.org` auth-gates (401) to upstream
  `logkeep_staging` (`100.64.0.1:8003`), but `logkeep-staging` +
  `logkeep-postgres-staging` containers are **exited since ~2026-10-30**; the
  endpoint would 502 past auth. Restart them or retire the vhost.

## Gatekeeper public ports

| Port | Protocol | Service |
|------|----------|---------|
| 80 | TCP | nginx → HTTPS redirect |
| 443 | TCP | nginx TLS |
| 44441 | TCP | sshd |
| 54321 | TCP | nginx stream proxy → pyrite PostgreSQL (`100.64.0.2:5432`) |
