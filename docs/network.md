# Network

## Topology docs

- [network overview](network/README.md)
- [local LAN and bonded link](network/lan.md)
- [tailnet notes](network/tailnet.md)

## Key design points

- Public ingress terminates on gatekeeper
- pyrite and arkk are LAN and tailnet peers
- Staging services are bound to the tailnet address when required
