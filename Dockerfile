FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libjpeg-dev \
    zlib1g-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --prefix=/install -r requirements.txt


# ---- Production stage ----
FROM python:3.12-slim

WORKDIR /app

# Create user
RUN adduser --disabled-password --gecos '' django-user

# Install minimal runtime libs (not dev headers)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    libjpeg62-turbo \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages
COPY --from=builder /install /usr/local

# Create static/media dirs
RUN mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

COPY ./app /app
COPY ./scripts /scripts

RUN chmod +x /scripts/*.sh && \
    chown -R django-user:django-user /app /scripts

USER django-user

CMD ["/scripts/run.sh"]
