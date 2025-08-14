ARG BUILD_FROM
FROM ${BUILD_FROM}
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG BUILD_ARCH
RUN apk add --no-cache postgresql postgresql-contrib redis fuse curl
RUN \
    echo "Determining download URL for architecture: ${BUILD_ARCH}..." \
    && case "${BUILD_ARCH}" in \
        "amd64") DOWNLOAD_URL="https://github.com/Adam7411/visionect_server/releases/download/v1.0.0-binaries/visionect_amd64.tar.gz" ;; \
        "armv7" | "aarch64") DOWNLOAD_URL="https://github.com/Adam7411/visionect_server/releases/download/v1.0.0-binaries/visionect_arm.tar.gz" ;; \
        *) echo "FATAL: Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac \
    && echo "Downloading from ${DOWNLOAD_URL}..." \
    && curl -L -o /tmp/visionect.tar.gz "${DOWNLOAD_URL}" \
    && echo "Unpacking binaries to root directory..." \
    && tar -xzf /tmp/visionect.tar.gz -C / \
    && echo "Cleaning up temporary file..." \
    && rm /tmp/visionect.tar.gz
COPY rootfs/ /
RUN chmod +x -R /etc/s6-overlay/
