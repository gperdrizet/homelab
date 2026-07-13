#!/usr/bin/env bash
# setup-dev-server.sh
#
# Deploys the containerized JupyterLab service bundle from this repo onto
# pyrite (or any tailnet node).
#
# Usage:
#   sudo bash setup-dev-server.sh [--user <username>] [--bind-ip <ip>] [--repo-root <path>]
#
# Defaults:
#   --user      siderealyear    (owner of the mounted home directory)
#   --bind-ip   auto-detected from tailscale0, fallback 127.0.0.1
#   --repo-root auto-detected from script location
#
# After running this script:
#   1. Edit /opt/jupyterlab/.env and replace CHANGE_ME with a real password hash
#   2. Start the service: sudo systemctl start jupyterlab
#   3. Verify Jupyter is reachable on this host:
#        curl -I http://<bind-ip>:47302

set -euo pipefail

# --- Configuration -----------------------------------------------------------

DEV_USER='siderealyear'
JUPYTER_PORT='47302'
BIND_IP=''
REPO_ROOT=''
SERVICE_SOURCE_DIR=''
DEPLOY_DIR='/opt/jupyterlab'
DEPLOY_CONFIG_DIR='/opt/jupyterlab/config'
DEPLOY_LAB_SETTINGS_DIR='/opt/jupyterlab/config/lab/settings'
DEPLOY_USER_THEME_DIR='/opt/jupyterlab/config/lab/user-settings/@jupyterlab/apputils-extension'
SYSTEMD_UNIT_PATH='/etc/systemd/system/jupyterlab.service'

# --- Argument parsing --------------------------------------------------------

while [[ $# -gt 0 ]]; do
    case "$1" in
        --user)
            [[ $# -ge 2 ]] || { echo "ERROR: --user requires a value." >&2; exit 1; }
            DEV_USER="$2"; shift 2 ;;
        --bind-ip)
            [[ $# -ge 2 ]] || { echo "ERROR: --bind-ip requires a value." >&2; exit 1; }
            BIND_IP="$2"; shift 2 ;;
        --repo-root)
            [[ $# -ge 2 ]] || { echo "ERROR: --repo-root requires a value." >&2; exit 1; }
            REPO_ROOT="$2"; shift 2 ;;
        *)
            echo "ERROR: Unknown argument: $1" >&2
            echo "Usage: sudo bash setup-dev-server.sh [--user <username>] [--bind-ip <ip>] [--repo-root <path>]" >&2
            exit 1 ;;
    esac
done

# --- Helper functions --------------------------------------------------------

log()  { echo "[setup-dev-server] $*"; }
die()  { echo "[setup-dev-server] ERROR: $*" >&2; exit 1; }
step() { echo; echo "==> $*"; }

[[ $EUID -eq 0 ]] || die "This script must be run as root (sudo)."
id "$DEV_USER" &>/dev/null || die "User '$DEV_USER' does not exist."

DEV_USER_HOME=$(getent passwd "$DEV_USER" | cut -d: -f6)

if [[ -z "$REPO_ROOT" ]]; then
    SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
    REPO_ROOT=$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)
fi

SERVICE_SOURCE_DIR="$REPO_ROOT/docs/machines/pyrite/services/jupyterlab"

[[ -d "$SERVICE_SOURCE_DIR" ]] || die "Service source directory not found: $SERVICE_SOURCE_DIR"
[[ -f "$SERVICE_SOURCE_DIR/docker-compose.yml" ]] || die "Missing docker-compose.yml in $SERVICE_SOURCE_DIR"
[[ -f "$SERVICE_SOURCE_DIR/.env.template" ]] || die "Missing .env.template in $SERVICE_SOURCE_DIR"
[[ -f "$SERVICE_SOURCE_DIR/jupyter_server_config.py" ]] || die "Missing jupyter_server_config.py in $SERVICE_SOURCE_DIR"
[[ -f "$SERVICE_SOURCE_DIR/lab/settings/overrides.json" ]] || die "Missing lab/settings/overrides.json in $SERVICE_SOURCE_DIR"
[[ -f "$SERVICE_SOURCE_DIR/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings" ]] || die "Missing user theme settings file in $SERVICE_SOURCE_DIR"
[[ -f "$SERVICE_SOURCE_DIR/jupyterlab.service" ]] || die "Missing jupyterlab.service in $SERVICE_SOURCE_DIR"

if [[ -z "$BIND_IP" ]]; then
    BIND_IP=$(ip -4 addr show tailscale0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | head -1 || true)
fi

if [[ -z "$BIND_IP" ]]; then
    BIND_IP='127.0.0.1'
    log "tailscale0 not found; falling back to bind IP $BIND_IP"
else
    log "Using tailscale bind IP: $BIND_IP"
fi

# --- Install dependencies ----------------------------------------------------

step "Installing system dependencies"
apt-get update -qq
apt-get install -y -qq docker-compose-plugin

# --- Prepare deployment directory --------------------------------------------

step "Preparing deployment directory"

mkdir -p "$DEPLOY_LAB_SETTINGS_DIR"
mkdir -p "$DEPLOY_USER_THEME_DIR"
mkdir -p "$DEV_USER_HOME"

install -m 644 "$SERVICE_SOURCE_DIR/docker-compose.yml" "$DEPLOY_DIR/docker-compose.yml"
install -m 644 "$SERVICE_SOURCE_DIR/jupyter_server_config.py" "$DEPLOY_CONFIG_DIR/jupyter_server_config.py"
install -m 644 "$SERVICE_SOURCE_DIR/lab/settings/overrides.json" "$DEPLOY_LAB_SETTINGS_DIR/overrides.json"
install -m 644 "$SERVICE_SOURCE_DIR/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings" "$DEPLOY_USER_THEME_DIR/themes.jupyterlab-settings"

if [[ ! -f "$DEPLOY_DIR/.env" ]]; then
    install -m 644 "$SERVICE_SOURCE_DIR/.env.template" "$DEPLOY_DIR/.env"
fi

sed -i "s|^TAILNET_IP=.*|TAILNET_IP=$BIND_IP|" "$DEPLOY_DIR/.env"
sed -i "s|^JUPYTER_PORT=.*|JUPYTER_PORT=$JUPYTER_PORT|" "$DEPLOY_DIR/.env"
sed -i "s|^HOST_HOME_DIR=.*|HOST_HOME_DIR=$DEV_USER_HOME|" "$DEPLOY_DIR/.env"

chown -R "$DEV_USER:$DEV_USER" "$DEPLOY_DIR"
log "Deployment files installed to $DEPLOY_DIR"

# --- Install systemd unit ----------------------------------------------------

step "Installing systemd unit"

install -m 644 "$SERVICE_SOURCE_DIR/jupyterlab.service" "$SYSTEMD_UNIT_PATH"
log "Systemd unit installed at $SYSTEMD_UNIT_PATH"

# --- Enable service ----------------------------------------------------------

step "Enabling services (not starting yet)"

systemctl daemon-reload
systemctl enable jupyterlab.service

log "Services enabled. They will start on next boot, or manually with:"
log "  sudo systemctl start jupyterlab"

# --- Print next steps --------------------------------------------------------

echo
echo "============================================================"
echo " Setup complete. Manual steps required before starting:"
echo "============================================================"
echo
echo "1. SET JUPYTER PASSWORD HASH in $DEPLOY_DIR/.env:"
echo "   Replace JUPYTER_PASSWORD_HASH='CHANGE_ME' with a real hash in single quotes"
echo "   Example hash generation command:"
echo "   python -c \"from jupyter_server.auth import passwd; print(passwd())\""
echo
echo "2. START JUPYTERLAB:"
echo "   sudo systemctl start jupyterlab"
echo
echo "3. VERIFY local response:"
echo "   curl -I http://$BIND_IP:$JUPYTER_PORT"
echo
echo "Access from the browser:"
echo "   JupyterLab: https://jupyter.perdrizet.org"
echo "============================================================"
