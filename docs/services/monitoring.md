# Monitoring

Two federated stacks: a public/internet-facing stack on gatekeeper and a
lab-internal stack on pyrite. Verified live 2026-11-18.

## gatekeeper stack (internet-facing)

Prometheus + Grafana + Loki + Alertmanager with exporters, all in the
`monitoring-*` containers:

| Container | Function | Bind |
|-----------|----------|------|
| monitoring-prometheus | metrics TSDB | `127.0.0.1:9090` |
| monitoring-grafana | dashboards | `127.0.0.1:3000` → grafana.perdrizet.org |
| monitoring-loki | log storage | `127.0.0.1:3100` |
| monitoring-promtail | log shipping | internal |
| monitoring-alertmanager | alert routing | `127.0.0.1:9093` |
| monitoring-node-exporter | host metrics | `127.0.0.1:9100` |
| monitoring-cadvisor | container metrics | internal |
| monitoring-nginx-exporter | nginx metrics | `127.0.0.1:9113` |
| monitoring-blackbox-exporter | HTTP/TLS probes | `127.0.0.1:9115` |
| bench-postgres-exporter | bench DB metrics | `127.0.0.1:9188` |
| logkeep-postgres-exporter | logkeep DB metrics | `127.0.0.1:9187` |

Config mirror:
[configs/monitoring/](../machines/gatekeeper/configs/monitoring/) —
scrapes pyrite services over the tailnet (LiteLLM/llama.cpp metrics,
`100.64.0.2:9187` postgres-exporter).

## pyrite stack (teaching demo — **not** the homelab monitoring plane)

pyrite also runs a local Prometheus + Grafana + postgres-exporter set bound to
the tailnet only. This belongs to the
[postgreSQL-server](https://github.com/gperdrizet/postgreSQL-server)
teaching/demo project (`~/postgreSQL-server`) — it is intentionally separate
from the gatekeeper plane. Don't mix homelab dashboards into it.

Historic detail: [operations/monitoring-inventory.md](../operations/monitoring-inventory.md)
(snapshot 2026-09-09; its `llamacpp-pyrite-batch` scrape targets are gone with
the old systemd llama.cpp units).

## LLM metrics

- LiteLLM router exposes Prometheus metrics on `:8502` — scraped by both stacks.
- llama.cpp servers expose `/metrics` internally; reached via router/docker
  network on pyrite.
