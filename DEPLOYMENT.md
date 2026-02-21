
# 🚀 Task Management API - Production Deployment Guide

This guide provides the necessary steps to build, test, and deploy the Task Management API using Docker and Kubernetes.

## 📋 Prerequisites
* **Docker:** 20.x+
* **Python:** 3.11+ (for local development)
* **Kubernetes:** `kubectl` + cluster access (kind, k3s, GKE, EKS, or AKS)
* **CI/CD:** GitHub repository with GHCR access

---

## 1. Local Docker Workflow

### 1.1 Build the Image
```bash
docker build -t do-uno:local .

```

### 1.2 Run the Container

```bash
docker run --rm -p 8000:8000 do-uno:local

```

**Key Endpoints:**

* **API:** `http://localhost:8000`
* **Docs:** `http://localhost:8000/docs`
* **Health:** `http://localhost:8000/health`

### 1.3 Verify & Cleanup

```bash
# Check health status
curl localhost:8000/health

# Run local tests
pytest test_app.py -v

# Stop local container
docker stop $(docker ps -q --filter ancestor=do-uno:local)

```

---

## 2. Kubernetes Deployment

### 2.1 Local Testing (via `kind`)

1. **Initialize cluster:**
```bash
brew install kind
kind create cluster --name do-uno
kind load docker-image do-uno:local --name do-uno

```


2. **Apply manifests:** *Ensure `k8s/deployment.yaml` uses `image: do-uno:local*`
```bash
kubectl apply -f k8s/
kubectl -n do-uno get pods  # Target: 3/3 Running

```


3. **Access the API:**
```bash
kubectl -n do-uno port-forward svc/do-uno-api 8000:80
curl localhost:8000/health

```



### 2.2 Production Deploy

1. Update `k8s/deployment.yaml` to point to the production registry:
`image: ghcr.io/prathamgoyal/do-exercise:latest`
2. Deploy to the production namespace:
```bash
kubectl apply -f k8s/
kubectl -n do-uno rollout status deployment/do-uno-api

```



---

## 3. CI/CD Pipeline

**Workflow:** `.github/workflows/ci-cd.yml`

| Stage | Action |
| --- | --- |
| **Test** | Runs `pytest test_app.py` |
| **Docker** | Builds and pushes to `ghcr.io/prathamgoyal/do-exercise:latest` |
| **Deploy** | Outputs image location for CD triggers |

---

## 4. Architecture & Security

### Feature Implementation

* **High Availability:** 3 Replicas (Pods)
* **Security:** Non-root user execution, defined resource limits
* **Health Checks:** Liveness, Readiness, and Startup probes configured
* **Base Image:** `python:3.11-slim` (~150MB)
* **Server:** `uvicorn` with 4 workers for production throughput

### Resource Allocation

* **Requests:** 250m CPU / 256Mi RAM
* **Limits:** 1 CPU / 512Mi RAM

---

## 5. Troubleshooting

* **`Pods CrashLoopBackOff`**: Run `kubectl logs -n do-uno deployment/do-uno-api`
* **`ImagePullBackOff`**: Check image tag spelling or registry authentication secrets.
* **Probes failing**: Verify the `/health` endpoint is reachable and returning a `200 OK`.
