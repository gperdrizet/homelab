# ethics-gradient

Daily-driver desktop workstation. Joined the fleet in 2026; audited live
2026-11-18.

## Hardware

**CPU:** Intel i5-12600KF (10c/16t)
**RAM:** 16 GB
**GPU:** NVIDIA GTX 1070 8 GB
**Storage:** ~240 GB SSD (`/dev/sda`, ext4)
**OS:** Ubuntu 26.04 LTS

## Network

- Home LAN (DHCP)
- Tailscale: **100.64.0.5** — the stable address; use this for service access.

## Role

- Primary interactive desktop: browser, VS Code, occasional Zoom + OBS.
- Hosts the **utility/embedding inference container** for the fleet:
  `llama-cuda` on `:8080`, serving Qwen3.5-4B and BGE-M3 via the
  [LiteLLM router on pyrite](../../services/inference.md).

## Services

| Service | Bind | Notes |
|---------|------|-------|
| llama-cuda (llama.cpp container) | `0.0.0.0:8080` | `--models-preset /config/presets.ini --models-max 2` |

!!! warning
    The inference port is published on all interfaces. Consider rebinding to
    `100.64.0.5:8080` to keep it tailnet-only.

## Operational notes

- Root disk at ~91 % (≈20 GB free) — needs cleanup; docker images + models
  live on root.
- No backups configured (desktop; personal data policy TBD).

## TODO

- Rebind llama-cuda to tailnet interface.
- Free root disk space (prune docker images, move models off root if possible).
- Document GPU/driver + CUDA container setup.
