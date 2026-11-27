# Forgejo (git.perdrizet.org)

Self-hosted git forge on **gatekeeper** (Codeberg fork of Gitea). Single
container, PostgreSQL backend on pyrite over the tailnet. Public git hosting;
registration disabled.

Verified against live container and nginx **2026-11-27** (deployed 2026-11-20,
admin created 2026-11-21).

## Request paths

```
browser ─https─▶ gatekeeper nginx (git.perdrizet.org) ─▶ 127.0.0.1:3300 (web / Smart HTTP)
git client ─ssh:2222─▶ gatekeeper 2222/tcp ─▶ container :22 (OpenSSH_10.2)
git client ─https─▶ ... 3300 (clone-HTTPS, buffering off for Smart HTTP)
app ─postgres TLS─▶ pyrite 100.64.0.2:5432  (db forgejo_db, role forgejo)
```

## Container (gatekeeper, compose project `forgejo`)

| Container | Image | Bind | Notes |
|-----------|-------|------|-------|
| forgejo | `codeberg.org/forgejo/forgejo:15` (LTS; live 15.0.12) | `127.0.0.1:3300→3000` (web), **`0.0.0.0:2222→22`** (git+ssh, public) | runs as uid 1000 (`git`) |

- `data/` volume (mounted at `/data`): repos (`git/`), LFS, ssh host keys
  (`ssh/`), app data. `app.ini` is **regenerated from `FORGEJO__*` env vars on
  every start** — edit the compose file, never `app.ini`.
- Config is fully env-driven; web installer disabled (`INSTALL_LOCK=true`).
- Policy: `DISABLE_REGISTRATION=true`, `REPO_REQUIRE_SIGNIN=false`
  (public read), min password length 16, OpenID signin/signup off.
- Live state at 2026-11-27: one user (`gperdrizet` <admin@bench.perdrizet.org>,
  admin), zero repositories yet.

## Ingress and TLS

- `git.perdrizet.org` → nginx `conf.d/forgejo.conf` → `127.0.0.1:3300`;
  `client_max_body_size 1024m` (LFS pushes), `proxy_buffering off` +
  `proxy_request_buffering off` (Smart HTTP), `proxy_read_timeout 300s`.
- **Combined Let's Encrypt cert** shared with Jitsi Meet: cert
  `git.perdrizet.org` (SAN: `git.perdrizet.org, meet.perdrizet.org`)
  terminates both vhosts (valid until 2027-02-18, checked 2026-11-27).

## Database (pyrite)

- PostgreSQL on **pyrite** `100.64.0.2:5432` over WireGuard;
  `sslmode=require` (pyrite `pg_hba` `hostssl` TLS + scram-sha-256 for
  `100.64.0.0/10`).
- db `forgejo_db`, role `forgejo` (owner, `PUBLIC` revoked). No local
  postgres container — this is what the public `:54321` nginx stream proxy
  also fronts (see [postgres](postgres.md)).

## Admin

- `docker exec --user git forgejo /usr/local/bin/forgejo admin user ...`
  (binary lives at `/usr/local/bin/forgejo` in the v15 image; CLI refuses
  root).
- Owner account: `gperdrizet` <admin@bench.perdrizet.org> — same identity as
  the Jitsi admin vhost.
- Gotchas documented in the runbook §4: `admin` is a reserved username;
  expand the password in the **host** shell or the account ends up with a
  blank password; v15 login form has no CSRF field.

## Deploy and operations

- Deploy repo: `/opt/forgejo` on gatekeeper, remote
  `git@github.com:gperdrizet/forgejo-setup.git` (upstream-less config repo:
  compose, `.env.example`, nginx vhost template, `scripts/create-db.sh`,
  runbook). `.env` (DB password) is mode 600, never committed.
- Runbook (full): `/opt/forgejo/docs/setup.md` on gatekeeper.
- Upgrades: stay within the `:15` LTS tag (`docker compose pull && up -d`);
  major bumps only after reading the release notes and taking the §6 backup.

## Backup

- **Database:** pyrite's `scripts/backup.sh` covers all databases — confirm
  `forgejo_db` stays included (`pg_dumpall -g` for the role).
- **Files:** tar `/opt/forgejo/data/` (repos, LFS, generated config, ssh host
  keys). Host keys persisting means clients' `known_hosts` survive upgrades.

## Monitoring

- **Not a Prometheus scrape target** (gap, 2026-11-27). Forgejo exposes a
  `/api/v1/metrics` (requires admin token) that could be scraped if wanted.

## Notes

- DNS: `git.perdrizet.org` A → `74.208.107.78` (verified 2026-11-27; an
  earlier wrong-IP issue noted in the runbook is resolved).
- Port 2222/tcp is public and firewalled-open (verified reachable from pyrite
  2026-11-27, banner `SSH-2.0-OpenSSH_10.2`).
- Live vhost mirrored at
  [configs/nginx/conf.d/forgejo.conf](../machines/gatekeeper/configs/nginx/conf.d/forgejo.conf).
