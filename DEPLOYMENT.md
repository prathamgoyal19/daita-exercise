# Deployment Guide – Task Management API

## Prerequisites

- Docker installed (20.x or later)
- Python 3.11+ (for local dev)
- `kubectl` configured for target cluster
- A container registry (example: GitHub Container Registry `ghcr.io`)
- Kubernetes cluster (e.g., kind, k3s, GKE, EKS, AKS)

---

## 1. Running Locally with Docker

### 1.1 Build image

```bash
# From repo root
docker build -t do-uno:local .
