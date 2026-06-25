# syntax=docker/dockerfile:1.7

ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}-slim-bookworm AS builder

WORKDIR /build

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && apt-get update && apt-get upgrade -y \
    && pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

FROM python:${PYTHON_VERSION}-slim-bookworm AS runtime

RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 10001 app \
    && useradd --uid 10001 --gid app --create-home --shell /usr/sbin/nologin app

WORKDIR /app

COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/* \
    && rm -rf /wheels

COPY --chown=app:app app/ ./app/
# requirements.txt not needed at runtime — remove this COPY
# (already installed from wheels; including it adds nothing but attack surface)

USER app

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/healthz')" || exit 1

# Pin worker class explicitly — avoids silent fallback to default if uvloop/httptools absent
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080", \
     "--loop", "uvloop", "--http", "httptools"]