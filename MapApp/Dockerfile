########################
# 1️⃣ Builder stage
########################
FROM python:3.11-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    portaudio19-dev \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


########################
# 2️⃣ Runtime stage
########################
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Runtime-only dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    portaudio19-dev \
    ffmpeg \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Copy only installed Python packages
COPY --from=builder /install /usr/local

COPY . .

# Non-root user (best practice)
RUN useradd -u 1000 appuser && chown -R appuser /app
USER appuser

EXPOSE 5000
CMD ["python", "-u", "app.py"]
