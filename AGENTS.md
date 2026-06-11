# homelab — Agent Instructions

Personal computing infrastructure for the gperdrizet homelab.
Three machines: **gatekeeper** (VPS), **pyrite** (desktop/compute), **arkk** (NAS, recovering).

---

## Repo layout

```
machines/gatekeeper/   VPS — nginx, Docker apps, monitoring, Tailscale exit node
machines/pyrite/       Desktop — dev, GPU compute, llama.cpp, PostgreSQL, guides/
machines/arkk/         NAS — RAID storage, NFS (currently recovering from drive failure)
network/               Topology, Tailscale/Headscale config, bonded LAN link docs
secrets/               Secrets strategy (Vaultwarden) + docker-compose placeholder
backups/               restic backup strategy and scripts
docker-images/         Link to gperdrizet/docker-images repo
```

Full service/port/domain inventory: [machines/gatekeeper/docs/services.md](machines/gatekeeper/docs/services.md)  
Directory layout and container lists: [machines/gatekeeper/docs/infrastructure-layout.md](machines/gatekeeper/docs/infrastructure-layout.md)

---

## Machines

| Machine    | IP / hostname     | Tailscale IP | SSH |
|------------|-------------------|--------------|-----|
| gatekeeper | 74.208.107.78     | 100.64.0.1   | `ssh siderealyear@74.208.107.78 -p 44441` or `ssh gatekeeper` |
| pyrite     | home office (LAN) | 100.64.0.2   | `ssh pyrite` (via Tailscale) |
| arkk       | home office (LAN) | TBD          | offline — recovering |

User on gatekeeper: `siderealyear`

---

## Key conventions

- **Secrets never in git.** `.env` files are gitignored. Templates (`.env.template`) are committed. Real values live in Vaultwarden (self-hosted Bitwarden on gatekeeper).
- **Tailscale-only staging.** Staging instances of all apps are bound to `100.64.0.1` (gatekeeper's Tailscale IP) and are not publicly accessible.
- **nginx configs are version-controlled** in `machines/gatekeeper/configs/nginx/conf.d/`. After editing, copy to `/etc/nginx/conf.d/` on gatekeeper and run `sudo nginx -t && sudo systemctl reload nginx`.
- **Monitoring configs** live in `machines/gatekeeper/configs/monitoring/`. After editing `prometheus.yml`, redeploy: `cd /srv/infra && docker compose -f docker-compose.monitoring.yml -p infra up -d --force-recreate prometheus`.
- **Commit scope prefixes**: `fix:`, `feat:`, `docs:`, `chore:` — match the existing commit style.

---

## Infrastructure status notes

- gatekeeper runs Docker for all app stacks. The only non-Docker services on the host are nginx, headscale (systemd), and `perdrizet-admin` (systemd, uvicorn on :8600).
- logkeep production is currently **down** (mid-update — blue/green containers stopped).
- BTCPay stack is **stopped** (not in active use).
- arkk is **offline** (RAID drive replacement in progress).
- `/opt/spark/` on gatekeeper is **decommissioned** — ignore it.
- model-gateway serves the OpenAI-compatible LLM API. Primary public domain: `promptlyapi.com`. Legacy: `model.perdrizet.org`.

---

## External repos (documented here, maintained separately)

- [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp) — inference server on pyrite
- [gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server) — PostgreSQL on pyrite
- [gperdrizet/docker-images](https://github.com/gperdrizet/docker-images) — custom Docker base images
