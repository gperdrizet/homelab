# JupyterLab on pyrite

This directory defines the target deployment for the remote JupyterLab service
on pyrite.

Deployment model:
- Runtime: Docker container on pyrite
- Image source: curated development images from the `docker-images` repo
- Public ingress: `jupyter.perdrizet.org` on gatekeeper nginx
- Private backend path: gatekeeper nginx -> `100.64.0.2:47302` over tailnet
- Service manager: systemd unit that runs `docker compose`

This repo is the infrastructure source of truth for the deployment wiring,
ingress, and operating model. The Docker image itself belongs in the separate
`docker-images` repo.

## Files

- `docker-compose.yml`: canonical container definition for pyrite
- `.env.template`: deployment variables to copy to `.env` on pyrite
- `jupyter_server_config.py`: Jupyter server settings consumed by the container
- `jupyterlab.service`: systemd unit template to manage the compose project

## Intended host layout

Deploy these files to `/opt/jupyterlab/` on pyrite:

```text
/opt/jupyterlab/
├── docker-compose.yml
├── .env
└── config/
    ├── jupyter_server_config.py
    └── lab/
        ├── settings/
        │   └── overrides.json
        └── user-settings/
            └── @jupyterlab/
                └── apputils-extension/
                    └── themes.jupyterlab-settings
```

Install the unit file at `/etc/systemd/system/jupyterlab.service`.

## Apply steps

1. Run [setup-dev-server.sh](../../../gatekeeper/tailnet/scripts/setup-dev-server.sh) as root on pyrite.
2. Edit `/opt/jupyterlab/.env` and set `JUPYTER_PASSWORD_HASH` to a real value wrapped in single quotes.
3. Run `sudo systemctl start jupyterlab`.

## Verify steps

1. `sudo systemctl status jupyterlab.service`
2. `docker compose --project-directory /opt/jupyterlab ps`
3. `curl -I http://100.64.0.2:47302`
4. Open `https://jupyter.perdrizet.org` and confirm login prompt + notebook UI
5. Confirm kernels and websocket-backed notebook execution work through the proxy

## Notes

- Keep Jupyter authentication enabled. Public access is mediated by gatekeeper,
  but Jupyter still needs its own password.
- The deployed image is `gperdrizet/kaggle-nvidia:6.0.1`.
- The deployment passes GPU `0` through to the container using Docker CDI (`nvidia.com/gpu=0`), which is the Tesla P100 on pyrite.
- The container mounts the full home directory of the target user at `/workspace`.
- JupyterLab defaults to the `JupyterLab Dark` theme via `config/lab/settings/overrides.json` and `config/lab/user-settings/@jupyterlab/apputils-extension/themes.jupyterlab-settings`.