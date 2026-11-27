# Jitsi Meet (meet.perdrizet.org)

Self-hosted video meetings on **gatekeeper**. Docker deployment of upstream
`jitsi/docker-jitsi-meet` pinned at tag `stable-11509-1` (upstream files
vendored unmodified). JWT-authenticated, members-only: no anonymous rooms, no
guests.

Verified against live containers, prosody config, and nginx **2026-11-27**
(deployed 2026-11-20, auth + members-only door 2026-11-20/21).

## Components (gatekeeper, compose project `jitsi-meet`)

| Container | Image | Bind | Purpose |
|-----------|-------|------|---------|
| jitsi-meet-web-1 | `ghcr.io/jitsi/web:stable-11509-1` | `127.0.0.1:9080→8000`, `127.0.0.1:9443→8443` | web client; internal HTTPS unused (`DISABLE_HTTPS=1`) |
| jitsi-meet-prosody-1 | `ghcr.io/jitsi/prosody:stable-11509-1` | `5222/5269/5280/5347` (compose network only) | XMPP server, MUCs, JWT gate |
| jitsi-meet-jicofo-1 | `ghcr.io/jitsi/jicofo:stable-11509-1` | `127.0.0.1:8888→8888` | focus component; REST API |
| jitsi-meet-jvb-1 | `ghcr.io/jitsi/jvb:stable-11509-1` | **`0.0.0.0:10000/udp`** (public), `127.0.0.1:8080→8080` | video bridge; colibri REST on loopback |

Media path: browsers ↔ **udp/10000** public (JVB), `JVB_ADVERTISE_IPS=74.208.107.78`.
Signaling: `wss://meet.perdrizet.org/xmpp-websocket` (web container → prosody).

> **Known gap: no TURN server.** No `TURN_*` vars are set, so peers behind
> symmetric/restrictive NAT that can't reach udp/10000 have no TCP/TURN
> fallback. Optional fallback is documented in the runbook §6 (tcp/4443).

## Ingress and TLS

- `meet.perdrizet.org` → nginx `conf.d/jitsi-meet.conf` → `127.0.0.1:9080`;
  websocket upgrades for `/xmpp-websocket` and `/colibri-ws/`,
  `proxy_read/send_timeout 600s` for long-lived XMPP sessions.
- **Combined Let's Encrypt cert** `git.perdrizet.org` (SAN:
  `git.perdrizet.org, meet.perdrizet.org`) terminates both subdomains; the
  meet vhost references the cert stored under `git.perdrizet.org`.
  Renewed via certbot; valid until 2027-02-18 (checked 2026-11-27).

## Auth (live)

- `.env`: `ENABLE_AUTH=1`, `ENABLE_GUESTS=0`, `PROSODY_AUTH_TYPE=jwt`,
  `JWT_APP_ID=bench`, `JWT_SIGN_TYPE=HS256`, `JWT_ALLOW_EMPTY=0`,
  `JWT_ENABLE_DOMAIN_VERIFICATION=false`.
- Rendered prosody (verified in-container 2026-11-27):
  - `VirtualHost "meet.jitsi"` → `authentication = "token"` (JWT MUC gate)
  - `VirtualHost "auth.meet.jitsi"` → `internal_hashed`
  - `VirtualHost "bench.perdrizet.org"` (second login vhost) →
    `internal_hashed`, admins `{ "admin@bench.perdrizet.org" }`,
    `s2s_in/out = false` (login-only domain)
- **Members-only door:** the bare domain serves a custom `members-only.html`
  room-picker (`welcomePage.customUrl=/members-only`, files under
  `/opt/jitsi-meet-config/web/`); rooms go to prejoin where the native login
  dialog appears. Unauthenticated MUC presences are dropped server-side
  (verified: stanzarouter drops `c2s_unauthed` presence).
- The owner admin identity is `admin@bench.perdrizet.org` (one identity across
  all platforms). Accounts persist in the prosody datastore across recreate.

## Data and secrets

- Persistent config/state: `/opt/jitsi-meet-config/` (prosody datastore +
  accounts, rendered configs, web custom files). Backup: tar this tree.
- XMPP component secrets: `/opt/jitsi-meet/.env` (mode 600, never committed)
  — include in the secret backup.

## Deploy and operations

- Deploy repo: `/opt/jitsi-meet` on gatekeeper — **local git repo, no remote**
  (upstream `docker-compose.yml`/`env.example`/`gen-passwords.sh` vendored
  unmodified at `stable-11509-1`; ours: `.env`, `env.template`, `nginx/`,
  `docs/setup.md`).
- Runbook (full): `/opt/jitsi-meet/docs/setup.md` on gatekeeper — install,
  relocation, auth mode, upgrades, verification checklist, gotchas.
- Convenience: `make up|down|pull|ps|logs|config-check`.
- Upgrades: bump `JITSI_IMAGE_VERSION` in `.env`, tar `$CONFIG` first,
  recreate (`docker compose up -d web prosody jicofo jvb`).
- The repo `README.md` line "open meeting room creation, no accounts
  (`ENABLE_AUTH=0`)" is **stale** — live mode is JWT-authenticated (above).

## Monitoring

- **Not a Prometheus scrape target** — no Jitsi/prosody metrics in the
  central plane (gap, 2026-11-27). Blackbox probe for the endpoint also
  absent.

## Notes

- DNS: `meet.perdrizet.org` A → `74.208.107.78` (verified 2026-11-27; an
  earlier wrong-IP issue noted in the runbook is resolved).
- Live vhost mirrored at
  [configs/nginx/conf.d/jitsi-meet.conf](../machines/gatekeeper/configs/nginx/conf.d/jitsi-meet.conf).
