# Promptly API (model gateway)

Public inference API at **promptlyapi.com**. Runs on gatekeeper; inference is
delegated to pyrite over the tailnet.

## Request path

```
client ─https─▶ gatekeeper nginx (promptlyapi.com)
              ─▶ model-gateway-api 127.0.0.1:8503
              ─▶ LiteLLM router 100.64.0.2:8502
              ─▶ llama.cpp servers (see [inference](inference.md))
```

## Containers (gatekeeper)

| Container | Image | Bind | Notes |
|-----------|-------|------|-------|
| model-gateway-api | `model-gateway-api` | `127.0.0.1:8503`, `100.64.0.1:8507` | production API |
| model-gateway-db | `postgres:16-alpine` | internal | prod DB |
| model-gateway-adminer | `adminer:4` | `100.64.0.1:8504` | DB admin, tailnet only |
| model-gateway-api-staging | `staging-api` | `127.0.0.1:8505`, `100.64.0.1:8507*` | staging |
| model-gateway-db-staging | `postgres:16-alpine` | internal | staging DB |
| model-gateway-adminer-staging | `adminer:4` | `100.64.0.1:8506` | staging DB admin |

## Nginx

- `promptlyapi.com` + `www` → `127.0.0.1:8503`; `/register` rate-limited
  (signup zone `3r/m`, burst 2) against spam sign-ups.
- `model.perdrizet.org` → **also proxies** to `127.0.0.1:8503`
  (`conf.d/model.conf`) — a second public alias of the gateway, not a redirect.
- Proxy read/send timeout 600 s (long generations).
- Live config mirrored at
  [configs/nginx/conf.d/promptlyapi.conf](../machines/gatekeeper/configs/nginx/conf.d/promptlyapi.conf).

## Notes / open questions

- Both prod and staging API containers map `100.64.0.1:8507`; confirm which
  one actually owns the port (docker shows both; only one can bind).
- Upstream LiteLLM endpoint is configured inside the app; changing the router
  address means an app config change, not nginx.
