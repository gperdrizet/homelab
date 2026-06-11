# Network

## Topology docs

- [network overview](https://github.com/gperdrizet/homelab/blob/main/network/README.md)
- [local LAN and bonded link](https://github.com/gperdrizet/homelab/blob/main/network/lan.md)
- [tailnet notes](https://github.com/gperdrizet/homelab/blob/main/network/tailnet.md)

## Key design points

- Public ingress terminates on gatekeeper
- pyrite and arkk are LAN and tailnet peers
- Staging services are bound to the tailnet address when required
