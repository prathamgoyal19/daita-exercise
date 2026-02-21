# syntax=docker/dockerfile:1

# ---- Base image ----
FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    UVICORN_WORKERS=4

# Create non-root user
RUN groupadd -r app && useradd -r -g app app

WORKDIR /app

# ---- System deps ----
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
    && rm -rf /var/lib/apt/lists/*

# ---- Python deps layer ----
COPY requirements.txt .
RUN python -m venv /opt/venv \
    && . /opt/venv/bin/activate \
    && pip install --upgrade pip \
    && pip install -r requirements.txt

ENV PATH="/opt/venv/bin:$PATH"

# ---- App code ----
COPY src/ src/
COPY test_app.py .

# Set a non-root user
USER app

# Expose the FastAPI port
EXPOSE 8000

# Healthcheck (basic, liveness covered by K8s)
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD curl -f http://127.0.0.1:8000/health || exit 1

# Run with production ASGI server
# If app is in src/app.py and FastAPI instance is "app"
CMD ["uvicorn", "src.app:app", "--host", "0.0.0.0", "--port", "8000"]
