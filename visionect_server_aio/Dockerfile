# =================================================================
# Wersja z poprawnymi uprawnieniami do skryptów
# =================================================================
ARG BUILD_FROM
ARG BUILD_ARCH_TAG
FROM visionect/visionect-server-v3:${BUILD_ARCH_TAG} as visionect_base
FROM ${BUILD_FROM}
RUN apk add --no-cache postgresql postgresql-contrib redis fuse
COPY --from=visionect_base /usr/local/ /usr/local/
COPY rootfs/ /
# Ta linijka jest wciąż kluczowa, aby skrypty mogły się uruchomić:
RUN chmod +x -R /etc/cont-init.d /etc/services.d
