# Machines

## Overview

- [gatekeeper machine docs](https://github.com/gperdrizet/homelab/blob/main/machines/gatekeeper/README.md)
- [pyrite machine docs](https://github.com/gperdrizet/homelab/blob/main/machines/pyrite/README.md)
- [arkk machine docs](https://github.com/gperdrizet/homelab/blob/main/machines/arkk/README.md)

## Pyrite published runbooks

- [Pyrite overview](../machines/pyrite/README.md)
- [Platform baseline](../machines/pyrite/docs/platform-baseline.md)
- [Boot and startup](../machines/pyrite/docs/boot-and-startup.md)
- [Wayland and AV](../machines/pyrite/docs/wayland-and-av.md)
- [Remote access](../machines/pyrite/docs/remote-access.md)
- [Troubleshooting](../machines/pyrite/docs/troubleshooting.md)
- [Change log](../machines/pyrite/docs/change-log.md)
- [Platform TODO](../machines/pyrite/docs/TODO.md)

## Core services on pyrite

- llama.cpp (8502)
- PostgreSQL (5432, public via gatekeeper stream proxy 54321)
- nixx (8000, proxied through gatekeeper)

## Service details

- [pyrite services](../machines/pyrite/services/README.md)
- [pyrite service roadmap todo](../machines/pyrite/services/TODO.md)
