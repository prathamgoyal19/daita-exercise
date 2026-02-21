# 🚀 Task Management API - Production Deployment Guide

## Prerequisites
- Docker 20.x+
- Python 3.11+ (local dev)
- kubectl + Kubernetes cluster (kind/k3s/GKE/EKS/AKS)
- GitHub repo for CI/CD (GHCR)

---

## 1. Local Docker

### 1.1 Build

docker build -t do-uno:local .
## 1.2 Run
bash
docker run --rm -p 8000:8000 do-uno:local
Endpoints:
API: http://localhost:8000
Docs: http://localhost:8000/docs
Health: http://localhost:8000/health
1.3 Verify
bash
curl localhost:8000/health
pytest test_app.py -v
docker stop $(docker ps -q --filter ancestor=do-uno:local)
2. Kubernetes
2.1 Local Testing (kind)
bash
brew install kind
kind create cluster --name do-uno
kind load docker-image do-uno:local --name do-uno

# Edit k8s/deployment.yaml → image: do-uno:local
kubectl apply -f k8s/
kubectl -n do-uno get pods  # 3/3 Running
kubectl -n do-uno port-forward svc/do-uno-api 8000:80
curl localhost:8000/health
2.2 Production Deploy
bash
# Update k8s/deployment.yaml:
# image: ghcr.io/prathamgoyal/do-exercise:latest
kubectl apply -f k8s/
kubectl -n do-uno rollout status deployment/do-uno-api
3. CI/CD Pipeline
GitHub Actions: .github/workflows/ci-cd.yml
text
test    → pytest test_app.py
docker  → ghcr.io/prathamgoyal/do-exercise:latest
deploy  → Print image location
CI Status

Latest image: ghcr.io/prathamgoyal/do-exercise:latest
4. Architecture & Security
Feature	Implementation
Replicas	3 pods high availability
Security	Non-root user, resource limits
Health	Liveness/readiness/startup probes
Image	python:3.11-slim (150MB)
Server	uvicorn workers=4 production
Resource requests: 250m CPU / 256Mi RAM
Resource limits: 1 CPU / 512Mi RAM
5. Troubleshooting
text
Pods CrashLoopBackOff → kubectl logs -n do-uno deployment/do-uno-api
ImagePullBackOff → Check image tag/registry auth
Probes failing → Verify /health endpoint works
Production checklist:
 Update image tag in deployment.yaml
 kubectl apply -f k8s/
 Verify rollout status
 Port-forward or Ingress for access
Author: Pratham Goyal | CI/CD: Auto | Image: ghcr.io/prathamgoyal/do-exercise