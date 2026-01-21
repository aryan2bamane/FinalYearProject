# MapApp/Dockerfile
FROM python:3.11-slim

# Labels
LABEL maintainer="aryanbamane2@gmail.com" \
      description="Voice-Enabled GIS Map Application" \
      version="1.0"

# Install system dependencies (audio + utils)
RUN apt-get update && apt-get install -y \
    portaudio19-dev \
    libasound2-dev \
    libsndfile1 \
    ffmpeg \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first (cache layer)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN useradd --create-home --shell /bin/bash appuser \
    && chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 5000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

# Production-ready entrypoint with eventlet
CMD ["sh", "-c", "eventlet app.py"]