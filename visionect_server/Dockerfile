ARG BUILD_FROM
FROM $BUILD_FROM

# Instalacja wymaganych pakietów
RUN apk add --no-cache \
    postgresql \
    postgresql-contrib \
    redis \
    su-exec \
    bash \
    curl

# Tworzenie katalogów
RUN mkdir -p /var/lib/postgresql/data \
    && mkdir -p /var/run/s6/container_environment

# Kopiowanie plików
COPY rootfs/ /
COPY run.sh /run.sh

# Ustawienie uprawnień
RUN chmod +x /run.sh \
    && chmod +x /etc/services.d/postgres/run \
    && chmod +x /etc/services.d/redis/run \
    && chmod +x /etc/services.d/visionect/run \
    && chown -R postgres:postgres /var/lib/postgresql

# Dodanie health checka
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8081/api/health || exit 1
