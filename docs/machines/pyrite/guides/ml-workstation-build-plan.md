# ML Workstation Build Plan

Planning reference for a future workstation refresh focused on local LLM inference and model training.

## Goals

- Run 70B parameter LLMs locally with large context for RAG and agentic applications.
- Faster DNN and regression training.
- Keep gaming capability on the same host.
- Preserve self-hosted, local-first operation.

## Candidate workstation profile

### Platform

| Component | Selection | Reasoning |
|-----------|-----------|-----------|
| Motherboard | ASUS Pro WS WRX80E-SAGE SE | 7x PCIe x16 slots, high lane count, 10GbE, IPMI support |
| CPU | AMD Threadripper Pro 5955WX (16-core) | Strong single-thread and lane availability |
| RAM | 8x 32GB DDR4 ECC (256GB) | ECC and memory headroom |
| Boot drive | SATA SSD (500GB+) | Simple and reliable OS disk |
| Scratch storage | 2x FireCuda 530 4TB NVMe | High-throughput RAID0 scratch |
| Chassis | Open-air frame or 4U chassis | Better multi-GPU thermals |

### GPUs

| GPU | Count | Role | VRAM |
|-----|-------|------|------|
| RTX 4090 | 1 | training, data science, gaming | 24GB |
| RTX 3090 | 2 | inference tensor split | 24GB x 2 |

## Storage and network design ideas

- Scratch RAID0 for active datasets and checkpoints.
- Separate high-capacity storage server for durable media and model archives.
- 10GbE direct link between workstation and storage node.

## Power and resilience

- Estimated full draw: ~1,350W.
- Target UPS class: ~3000VA for clean shutdown window.

## Cost planning snapshot

- Estimated workstation subtotal: ~$6,100 (used-market assumptions).
- Estimated storage-server subtotal: ~$2,300.
- Estimated UPS: ~$500.
- Combined estimate: ~$8,900.

## Notes

This is a planning document, not an active build runbook. When a build starts,
convert selected decisions into concrete implementation docs under the
appropriate machine directory.
