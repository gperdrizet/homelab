# Secrets management

> **Status: partly aspirational.** Vaultwarden is **planned but not yet deployed**. Today,
> infrastructure secrets live only in on-host `.env` files on each server (for example
> `/srv/infra/.env` on gatekeeper) - there is no central secret store or backup yet. Treat the
> on-host `.env` files as the source of truth and back them up manually until Vaultwarden is
> stood up. The sections below describe the intended end state; notes call out today's reality.

All secrets (passwords, API keys, tokens, and credentials) are managed through
two complementary systems. **No secrets are ever committed to this or any other repo.**

---

## Layer 1: Personal passwords and logins

**Tool:** [Vaultwarden](https://github.com/dani-garcia/vaultwarden) (self-hosted Bitwarden-compatible server)  
**Status:** planned - not yet deployed  
**Intended host:** gatekeeper (Docker container)  
**Access (once deployed):** Bitwarden browser extension, mobile app, or CLI (`bw`)  
**Setup:** `vaultwarden/` (template compose file in this directory; not yet running)  

Covers: Gmail, GitHub, domain registrar, cloud provider accounts, SSH passphrases, and
any other personal login.

---

## Layer 2: Infrastructure secrets (per-project)

Each project follows the `.env.template` pattern:

- `.env.template`: committed to the project repo. Contains all variable names with
  placeholder values and comments explaining each secret.
- `.env` / `.env.production` / `.env.staging`: **not committed** (in `.gitignore`).
  Contains real values. Stored on the server. **Today** this on-host copy is the only one -
  back it up manually. **Planned:** mirror each to Vaultwarden as a secure note.

**Intended:** Vaultwarden becomes the single source of truth for `.env` values, so a rebuilt
server can recover everything. **Today:** there is no central store - secrets exist only in the
on-host `.env` files, and are lost on rebuild unless separately backed up.

### Secrets inventory

A master list of all infrastructure secrets (by project, not their values) will be
maintained as a secure note in Vaultwarden once it is deployed. Until then, no such
central inventory exists - secrets live only in on-host `.env` files.

---

## What goes where

This is the **target** model. "Vaultwarden" entries are where each secret *will* live once it
is deployed; today those secrets live in on-host `.env` files (or the app/service itself).

| Type | Tool (target) |
|------|------|
| Gmail, GitHub, domain logins | Vaultwarden (planned) |
| SSH keys | `~/.ssh/` + passphrase in Vaultwarden (planned) |
| VPS `.env` files (API keys, DB passwords) | `.env` on server (Vaultwarden backup planned) |
| GitHub Actions secrets | GitHub repo settings |
| Stripe keys | Vaultwarden (planned) |
| Grafana admin password | on-host `/srv/infra/.env` on gatekeeper (Vaultwarden planned) |

---

## Vaultwarden (planned)

Vaultwarden is not yet running. See `vaultwarden/docker-compose.yml` (in this directory) for the
intended Docker compose setup; deploying it is a tracked TODO.
