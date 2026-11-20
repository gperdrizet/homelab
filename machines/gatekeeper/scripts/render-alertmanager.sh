#!/bin/bash
# Render /srv/infra/configs/alertmanager.yml from template + .env.
# Alertmanager (distroless, no env expansion in config) needs the values
# baked into the file; the container hot-reloads the mount within ~30 s.
# Credentials live ONLY in /srv/infra/.env — edit there, then run this.
set -euo pipefail
cd /srv/infra
set -a; . /srv/infra/.env; set +a
envsubst < configs/alertmanager.yml.template > configs/alertmanager.yml
chmod 644 configs/alertmanager.yml
echo "rendered: configs/alertmanager.yml ($(date -Is))"
