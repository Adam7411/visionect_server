# Używamy oficjalnego obrazu bazowego Home Assistant
ARG BUILD_FROM
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG BUILD_ARCH

# Instalacja zależności
RUN apk add --no-cache postgresql postgresql-contrib redis fuse

# Kopiowanie plików binarnych, które zostały stworzone w poprzednim kroku akcji
COPY tmp_build/ /tmp/bin/

# Rozpakowywanie plików binarnych Visionect
RUN \
    echo "Unpacking binaries for architecture: ${BUILD_ARCH}..." \
    && case "${BUILD_ARCH}" in \
        "amd64") tar -xzf /tmp/bin/visionect_amd64.tar.gz -C / ;; \
        "armv7" | "aarch64") tar -xzf /tmp/bin/visionect_arm.tar.gz -C / ;; \
        *) echo "FATAL: Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac \
    && echo "Cleaning up temporary files..." \
    && rm -rf /tmp/bin

# Kopiowanie skryptów s6-overlay
COPY rootfs/ /
RUN chmod +x -R /etc/s6-overlay/
