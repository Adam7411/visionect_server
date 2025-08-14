ARG BUILD_FROM=ghcr.io/hassio-addons/base/amd64:13.1.2
FROM $BUILD_FROM

# Arch zmienna (ustawiana automatycznie przez HA)
ARG BUILD_ARCH

# Instalacja Postgres i Redis
RUN apk add --no-cache postgresql postgresql-contrib redis bash fuse

# Pobranie właściwego obrazu Visionect w zależności od architektury
# i skopiowanie binariów
RUN case "$BUILD_ARCH" in \
    "amd64")   export VISIONECT_IMAGE="visionect/visionect-server-v3:7.6.5" ;; \
    "armv7")   export VISIONECT_IMAGE="visionect/visionect-server-v3:7.6.5-arm" ;; \
    "aarch64") export VISIONECT_IMAGE="visionect/visionect-server-v3:7.6.5-arm" ;; \
    *) echo "Unsupported architecture: $BUILD_ARCH" && exit 1 ;; \
    esac && \
    echo "Using Visionect image: $VISIONECT_IMAGE" && \
    docker run --rm $VISIONECT_IMAGE tar -C /usr/local -cf - . | tar -C /usr/local -xf -

# Kopiowanie skryptów uruchamiających
COPY rootfs/ /

# Uprawnienia
RUN chmod +x /etc/services.d/*/run

EXPOSE 8081 11113

CMD [ "/run.sh" ]
