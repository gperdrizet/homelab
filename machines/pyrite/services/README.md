# Services on pyrite

This page documents the services running on pyrite that are accessible from
the rest of the homelab. Each service is maintained in its own repo.

Planned additions and infrastructure follow-up tasks are tracked in
[TODO.md](TODO.md).

Platform-level workstation setup and tuning notes are tracked in
../docs/.

---

## llama.cpp inference server

**Repo:** [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp)  
**Port:** 8502 (tailnet path from gatekeeper to 100.64.0.2)  
**Backend for:** model-gateway on gatekeeper (promptlyapi.com, model.perdrizet.org)

---

## PostgreSQL server

**Repo:** [gperdrizet/postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server)  
**Port:** 5432 (local) → 54321 (public via gatekeeper TCP stream proxy)  
**Used by:** external clients connecting to pyrite's database over the internet

---

## nixx server

**Repo:** [gperdrizet/nixx](https://github.com/gperdrizet/nixx)  
**Port:** 8000 (tailnet path from gatekeeper to 100.64.0.2)  
**Used by:** nixx.perdrizet.org reverse proxy on gatekeeper

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
