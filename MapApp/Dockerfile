########################
# 1️⃣ Builder stage
########################
FROM python:3.11-slim AS builder

WORKDIR /build

# Build deps (ONLY here)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    portaudio19-dev \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install Python deps into a temp directory
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


########################
# 2️⃣ Runtime stage
########################
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Runtime-only libs (NO compiler)
RUN apt-get update && apt-get install -y --no-install-recommends \
    portaudio19-dev \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Copy prebuilt Python packages
COPY --from=builder /install /usr/local

COPY . .

RUN useradd -u 1000 appuser && chown -R appuser /app
USER appuser

EXPOSE 5000
CMD ["python", "-u", "app.py"]
