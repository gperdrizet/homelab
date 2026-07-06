# Incidents and resilience

Operational incident records for gatekeeper, with the fixes applied and the
hardening still recommended. Kept short and action-oriented.

---

## 2026-07-01 → 07-05: total public ingress outage (nginx ↔ tailnet deadlock)

**Impact:** every public site down for ~3 days — perdrizet.org, logkeep, bench,
bug-hunter, feedback, model-gateway/promptlyapi, grafana, code, jupyter, plus the
tailnet itself. All containers stayed healthy; only ingress was broken. The
outage went unnoticed because alerting also runs behind the failed ingress.

**Root cause — a bootstrap deadlock:**

1. An nginx listener binds directly to the Tailscale IP `100.64.0.1:8012`.
2. Tailscale/headscale dropped, so `100.64.0.1` disappeared from `tailscale0`.
3. `nginx -t` then fails with `bind() to 100.64.0.1:8012 failed` → the **entire**
   nginx service fails to start (systemd shows `failed`).
4. With nginx down, `headscale.perdrizet.org` (TLS-terminated by nginx →
   `127.0.0.1:8090`) is unreachable from the internet, so Tailscale clients on
   both gatekeeper and pyrite can't re-auth → `100.64.0.1` never returns → nginx
   can never bind it. Deadlock.

**Fix applied:**

```bash
sudo sysctl -w net.ipv4.ip_nonlocal_bind=1
echo 'net.ipv4.ip_nonlocal_bind=1' | sudo tee /etc/sysctl.d/99-nonlocal-bind.conf
sudo systemctl start nginx     # headscale.perdrizet.org back
sudo tailscale up              # gatekeeper re-auths, 100.64.0.1 returns
# then on pyrite: sudo tailscale up
```

`ip_nonlocal_bind=1` lets nginx bind an address that isn't up yet, so a Tailscale
hiccup can no longer take down all public ingress.

---

## 2026-07: headplane can't reach headscale (ufw subnet drift)

**Symptom:** headplane login fails with "Error while validating API key" for any
key, valid or not.

**Root cause:** headplane (container on `logkeep_logkeep-network`) reaches
headscale via `host.docker.internal:8090`. A ufw rule allowed the headscale API
only from `172.20.0.0/16`, but Docker had reassigned that network to
**`172.18.0.0/16`**. The container's packets to headscale:8090 were denied, so
headplane could never validate a key. (A coincidentally-expired config key sent
the initial diagnosis down the wrong path — the key was a red herring.)

**Fix applied — drift-proof ufw rule:**

```bash
sudo ufw allow from 172.16.0.0/12 to any port 8090 proto tcp comment "docker to headscale API"
sudo ufw reload
```

Verify a container on the network can reach headscale (expect `200`):

```bash
docker run --rm --network logkeep_logkeep-network \
  --add-host host.docker.internal:host-gateway curlimages/curl:latest \
  -s -o /dev/null -w '%{http_code}\n' http://host.docker.internal:8090/health
```

---

## Recommendations

### 1. Offsite uptime monitoring + alerting (highest priority)

The 3-day outage was invisible because Prometheus/Alertmanager/Grafana all sit
behind the same gatekeeper ingress that failed — when ingress dies, so does
alerting. Add an **external** check that does not depend on gatekeeper:

- A hosted uptime monitor (healthchecks.io, UptimeRobot, or similar) probing
  `https://perdrizet.org` and `https://headscale.perdrizet.org`, alerting to
  email/phone.
- Or a cron probe from pyrite/arkk over the public internet.

### 2. Pin Docker network subnets

Subnet drift silently broke the headscale firewall rule. Pin the subnet in the
compose file so it never moves:

```yaml
networks:
  logkeep-network:
    ipam:
      config:
        - subnet: 172.18.0.0/16
```

Keep the ufw rules on the broad `172.16.0.0/12` range as defense in depth. The
metrics rules (`9099/tcp` from `172.17/172.19/172.20`) have the same drift risk —
widen them to `172.16.0.0/12` and confirm headscale metrics still scrape in
Grafana.

### 3. Decouple nginx from the tailnet IP at startup

`ip_nonlocal_bind=1` is the safety net, but also audit why a listener binds
`100.64.0.1:8012` at all. If that upstream can listen on `127.0.0.1` or `0.0.0.0`
instead, nginx never depends on the tailnet being up.

### 4. headscale API key hygiene

The headplane config key expired silently (90-day default). Use a long-lived key
for service-to-service auth and note its expiry, or add a check that alerts
before headscale API keys expire. Never paste generated keys into a shell that
is being screen-shared or logged — treat any exposed key as compromised and
`headscale apikeys expire --prefix <prefix>`.

### 5. Tailscale auto-recovery

Ensure `tailscaled` re-authenticates automatically after headscale returns
(persistent auth key / `--auth-key`) so a control-plane blip self-heals instead
of requiring a manual `tailscale up` on each node.
