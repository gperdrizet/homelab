# Remote access

Remote access methods for pyrite.

## Primary paths

1. Tailscale access:
- Host tailnet IP: 100.64.0.2
- Used by gatekeeper nginx upstreams for code and jupyter endpoints.

2. VS Code tunnel:
- Tunnel name: pyrite
- URL: https://vscode.dev/tunnel/pyrite

## VS Code tunnel service

Install and persist as user service:
- code tunnel service install --accept-server-license-terms

Service controls:
- systemctl --user status code-tunnel.service
- systemctl --user restart code-tunnel.service
- systemctl --user stop code-tunnel.service
- systemctl --user start code-tunnel.service
- code tunnel service uninstall

Logs:
- code tunnel service log
- journalctl --user -u code-tunnel.service -f

## Recovery playbook

If tunnel breaks after update:
1. Restart service.
2. Re-check logs.
3. Reinstall service if missing.
4. Re-auth via GitHub device flow.

If multiple code-tunnel processes exist:
- Stop duplicates and keep only the systemd user service instance.
