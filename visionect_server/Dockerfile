ARG BUILD_FROM
FROM $BUILD_FROM

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install required packages
RUN apk add --no-cache \
    postgresql \
    postgresql-contrib \
    redis \
    su-exec \
    bash \
    curl \
    tzdata \
    s6-overlay

# Create directories
RUN mkdir -p /var/lib/postgresql/data \
    && mkdir -p /var/run/s6/container_environment \
    && mkdir -p /etc/services.d/postgres \
    && mkdir -p /etc/services.d/redis \
    && mkdir -p /etc/services.d/visionect

# Copy rootfs
COPY rootfs/ /

# Set permissions
RUN chmod +x /etc/services.d/postgres/run \
    && chmod +x /etc/services.d/redis/run \
    && chmod +x /etc/services.d/visionect/run \
    && chmod +x /run.sh \
    && chown -R postgres:postgres /var/lib/postgresql

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8081/api/health || exit 1

# Entrypoint
ENTRYPOINT ["/run.sh"]
