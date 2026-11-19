# JupyterLab

GPU-enabled JupyterLab on pyrite, publicly reachable through gatekeeper.

| Item | Value |
|------|-------|
| Container | `jupyterlab` (`gperdrizet/datascience-nvidia:6.0.1`) |
| Bind | `100.64.0.2:47302` (tailnet) |
| Ingress | jupyter.perdrizet.org (gatekeeper nginx → tailnet) |
| Deployment | `docker compose` + systemd unit, config in this repo |

Deployment files (compose, systemd unit, server config, lab overrides):
[machines/pyrite/services/jupyterlab/](../machines/pyrite/services/jupyterlab/README.md).

Image updates: the image comes from
[gperdrizet/docker-images](https://github.com/gperdrizet/docker-images); bump
the tag in the compose file and recreate.
