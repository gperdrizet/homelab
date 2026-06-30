# Pyrite service roadmap todo

Focused backlog for services to host on pyrite and the shared infrastructure work needed to run them reliably.

Note: workstation platform tasks (Wayland, boot, kernel tuning, tunnel operations) are tracked in https://github.com/gperdrizet/homelab/blob/main/docs/machines/pyrite/docs/TODO.md.

## New services to add

- [ ] Matrix server
  - [ ] Choose stack: Synapse or Dendrite
  - [ ] Decide where Element Web will run (gatekeeper nginx static/app proxy)
  - [ ] Persist media and DB on pyrite storage with backup coverage

- [ ] Immich photo album
  - [ ] Deploy Immich app + required workers
  - [ ] Attach persistent library storage path on pyrite
  - [ ] Validate hardware acceleration path for thumbnails/transcoding

- [ ] Vaultwarden
  - [ ] Decide host location: pyrite vs existing gatekeeper deployment
  - [ ] If pyrite-hosted, add nginx reverse proxy route via gatekeeper
  - [ ] Configure admin token handling and backup/restore test

- [ ] GitHub alternative
  - [ ] Choose platform: Forgejo or Gitea
  - [ ] Plan repo storage path and backup retention
  - [ ] Configure SSH + HTTPS git access through gatekeeper

## Already implied and related work

- [ ] Service ingress standardization
  - [ ] Domain naming plan for each new service
  - [ ] nginx vhost + TLS certbot wiring on gatekeeper
  - [ ] Tailscale/private-only policy for staging or admin endpoints

- [ ] Data and backup policy
  - [ ] Define backup class per service: database, media, repos, secrets
  - [ ] Add restore drill checklist for each service
  - [ ] Confirm retention windows and off-host copy targets

- [ ] Observability baseline
  - [ ] Add health checks and uptime probes
  - [ ] Add service metrics/log forwarding into existing monitoring stack
  - [ ] Add alerts for disk, memory, and service down events

- [ ] Auth and security baseline
  - [ ] MFA policy and admin account hardening
  - [ ] Secret placement in Vaultwarden and .env template updates
  - [ ] Rate limiting and security headers for public endpoints

- [ ] Pyrite capacity planning
  - [ ] Estimate storage growth (Immich media + git repos + Matrix media)
  - [ ] Validate RAM/CPU headroom for concurrent services
  - [ ] Define resource limits per container/service

## Existing pyrite core services (for context)

- llama.cpp (8502)
- PostgreSQL (5432)
- nixx (8000)
