# Use official Python runtime as parent image
FROM python:3.13-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# Set work directory
WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . /app/

# Create non-root user for security
RUN adduser --disabled-password --gecos '' appuser \
    && chown -R appuser:appuser /app

# Expose port
EXPOSE 8001

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8001/api/health/ || exit 1

# Switch to non-root user
USER appuser

# Start application with Gunicorn
# Collectstatic runs at startup to avoid build-time env var issues
CMD echo "=== STARTING DJANGO APP ===" && \
    echo "DEBUG: ${DEBUG}" && \
    echo "ALLOWED_HOSTS: ${ALLOWED_HOSTS}" && \
    python manage.py collectstatic --noinput && \
    echo "=== STARTING GUNICORN ON PORT 8001 ===" && \
    gunicorn --bind 0.0.0.0:8001 --workers 3 --timeout 120 --log-level debug --access-logfile - --error-logfile - myproject.wsgi:application
