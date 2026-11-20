# LLM inference stack

Two llama.cpp servers behind one LiteLLM router. Verified live 2026-11-18.

## Topology

```
promptlyapi.com ─▶ gatekeeper nginx ─▶ model-gateway-api (:8503)
                                          │ tailnet
                                          ▼
                              pyrite LiteLLM router (:8502)
                              │                        │
              docker llm-network                tailnet 100.64.0.5
                              ▼                        ▼
                 llama-cuda (pyrite)         llama-cuda (ethics-gradient)
                  :8080 (bridge only)          :8080 (host)
```

## LiteLLM router (pyrite)

- **Container:** `litellm-router` (`ghcr.io/berriai/litellm:main-latest`)
- **Bind:** `0.0.0.0:8502` → container `:8506`
- **Config:** `/opt/litellm/config.json` (mounted read-only at `/app/config.json`)
- **Models currently routed:**

| Model name | Upstream |
|------------|----------|
| Qwen3.8-27B | `http://llama-cuda:8080/v1` (pyrite) |
| Qwen3.8-Flash-Next | `http://llama-cuda:8080/v1` (pyrite) |
| Qwen3-Coder-Next | `http://llama-cuda:8080/v1` (pyrite) |
| Qwen3.5-4B | `http://100.64.0.5:8080/v1` (ethics-gradient) |
| BGE-M3 (embeddings) | `http://100.64.0.5:8080/v1` (ethics-gradient) |

## llama.cpp — pyrite (main inference)

- **Container:** `llama-cuda` (`ghcr.io/ggml-org/llama.cpp:server-cuda`)
- **Network:** `llm-network` bridge; **no published host port** — reached only
  via LiteLLM
- **Launch:** `--models-preset /config/presets.ini --models-max 1` — no
  `--metrics`; by design, inference is monitored at the LiteLLM router level
  ([monitoring](monitoring.md))
- **Config:** `/opt/llama/config` (presets.ini)
- **Models:** `/mnt/fast_scratch/llama-models`
- **GPU:** 2× Tesla P100 16 GB
- **Repo:** [gperdrizet/llama.cpp](https://github.com/gperdrizet/llama.cpp)

## llama.cpp — ethics-gradient (utility/embeddings)

- **Container:** `llama-cuda` (same image)
- **Bind:** `0.0.0.0:8080` (LAN + tailnet; see note)
- **Launch:** `--models-preset /config/presets.ini --models-max 2` — also no
  `--metrics`
- Serves the light models LiteLLM splits off from pyrite (Qwen3.5-4B, BGE-M3).

!!! warning "Bind scope"
    ethics-gradient publishes `:8080` on all interfaces including LAN. If it
    should be tailnet-only, rebind to `100.64.0.5:8080`.

## History / drift notes

- The old `llamacpp.service` systemd unit (binary at
  `/opt/llama.cpp/build/bin/llama-server`, direct `:8502`) is **gone**; the
  container + router replaced it. Older pages referencing the systemd unit or
  batch instances on `:8503`/`:8504` are stale.
