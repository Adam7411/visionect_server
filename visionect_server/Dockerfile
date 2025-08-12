ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.15
FROM ${BUILD_FROM}

# Install requirements
RUN apk add --no-cache \
    bash \
    curl \
    postgresql \
    postgresql-contrib \
    redis \
    su-exec \
    tzdata

# Copy root filesystem
COPY rootfs /

# Install Visionect Server based on architecture
ARG TARGETARCH
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        curl -L https://github.com/visionect/visionect-server-v3/releases/download/7.6.5/visionect-server-v3-7.6.5-linux-x86_64.tar.gz -o /tmp/visionect.tar.gz; \
    elif [ "$TARGETARCH" = "armv7" ]; then \
        curl -L https://github.com/visionect/visionect-server-v3/releases/download/7.6.5/visionect-server-v3-7.6.5-linux-armv7l.tar.gz -o /tmp/visionect.tar.gz; \
    elif [ "$TARGETARCH" = "aarch64" ]; then \
        curl -L https://github.com/visionect/visionect-server-v3/releases/download/7.6.5/visionect-server-v3-7.6.5-linux-arm64.tar.gz -o /tmp/visionect.tar.gz; \
    else \
        echo "Unsupported architecture: $TARGETARCH"; exit 1; \
    fi && \
    tar -xzf /tmp/visionect.tar.gz -C /opt && \
    rm /tmp/visionect.tar.gz && \
    chmod +x /opt/visionect-server-v3/bin/*

# Create PostgreSQL data directory
RUN mkdir -p /var/lib/postgresql/data && \
    chown -R postgres:postgres /var/lib/postgresql

# Set executable permissions for run.sh
RUN chmod +x /run.sh

# Labels
LABEL \
    io.hass.name="Visionect Server" \
    io.hass.description="Visionect Server with PostgreSQL and Redis" \
    io.hass.arch="amd64|armv7|aarch64" \
    io.hass.type="addon" \
    io.hass.version="7.6.5"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8081/health || exit 1

CMD [ "/run.sh" ]
