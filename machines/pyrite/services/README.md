# Services on pyrite

This page documents the services running on pyrite that are accessible from
the rest of the homelab. Each service is maintained in its own repo.

Planned additions and infrastructure follow-up tasks are tracked in
[TODO.md](TODO.md).

---

## llama.cpp inference server

**Repo:** [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp)  
**Port:** 8502 (Tailscale-accessible from gatekeeper)  
**Backend for:** model-gateway on gatekeeper (promptlyapi.com, model.perdrizet.org)

---

## PostgreSQL server

**Repo:** [gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server)  
**Port:** 5432 (local) → 54321 (public via gatekeeper TCP stream proxy)  
**Used by:** external clients connecting to pyrite's database over the internet

---

## nixx server

**Repo:** [gperdrizet/nixx](https://github.com/gperdrizet/nixx)  
**Port:** 8000 (Tailscale-accessible from gatekeeper)  
**Used by:** nixx.perdrizet.org reverse proxy on gatekeeper

---

## Docker images

**Repo:** [gperdrizet/docker-images](https://github.com/gperdrizet/docker-images)  
Custom Docker base images built and pushed to GHCR, used across projects on
both pyrite and gatekeeper.
