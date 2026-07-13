# Remote access

Remote access methods for pyrite.

## Primary paths

1. Tailscale access:
- Host tailnet IP: 100.64.0.2
- Used by gatekeeper nginx upstreams for Jupyter and service backends.

2. SSH over LAN or tailnet:
- LAN: `10.1.10.200`
- Tailnet: `100.64.0.2`

3. Browser notebook access:
- Public ingress: `https://jupyter.perdrizet.org`
- Proxy path: gatekeeper nginx -> `100.64.0.2:47302`

## Operational checks

- Verify tailnet connectivity:
	- `tailscale status`
- Verify Jupyter service:
	- `sudo systemctl status jupyterlab`
	- `docker ps --filter name=jupyterlab`
- Verify local Jupyter bind:
	- `curl -I http://100.64.0.2:47302`
