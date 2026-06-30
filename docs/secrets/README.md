# Secrets management

All secrets (passwords, API keys, tokens, and credentials) are managed through
two complementary systems. **No secrets are ever committed to this or any other repo.**

---

## Layer 1: Personal passwords and logins

**Tool:** [Vaultwarden](https://github.com/dani-garcia/vaultwarden) (self-hosted Bitwarden-compatible server)  
**Hosted on:** gatekeeper (Docker container)  
**Access:** Bitwarden browser extension, mobile app, or CLI (`bw`)  
**Setup:** [vaultwarden/](vaultwarden/)  

Covers: Gmail, GitHub, domain registrar, cloud provider accounts, SSH passphrases, and
any other personal login.

---

## Layer 2: Infrastructure secrets (per-project)

Each project follows the `.env.template` pattern:

- `.env.template`: committed to the project repo. Contains all variable names with
  placeholder values and comments explaining each secret.
- `.env` / `.env.production` / `.env.staging`: **not committed** (in `.gitignore`).
  Contains real values. Stored on the server and backed up to Vaultwarden as secure notes.

Vaultwarden is the single source of truth for what `.env` values are in use. If a
server is rebuilt, all secrets can be retrieved from there.

### Secrets inventory

A master list of all infrastructure secrets (by project, not their values) is
maintained as a secure note in Vaultwarden. This ensures nothing gets lost when
rotating keys or rebuilding servers.

---

## What goes where

| Type | Tool |
|------|------|
| Gmail, GitHub, domain logins | Vaultwarden |
| SSH keys | `~/.ssh/` + passphrase in Vaultwarden |
| VPS `.env` files (API keys, DB passwords) | `.env` on server + backup in Vaultwarden |
| GitHub Actions secrets | GitHub repo settings (reference name noted in Vaultwarden) |
| Stripe, BTCPay keys | Vaultwarden |
| Grafana admin password | Vaultwarden |

---

## Vaultwarden

See [vaultwarden/](vaultwarden/) for the Docker compose setup.
