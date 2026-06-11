# Services on pyrite

This page documents the services running on pyrite that are accessible from
the rest of the homelab. Each service is maintained in its own repo.

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

## Docker images

**Repo:** [gperdrizet/docker-images](https://github.com/gperdrizet/docker-images)  
Custom Docker base images built and pushed to GHCR, used across projects on
both pyrite and gatekeeper.
