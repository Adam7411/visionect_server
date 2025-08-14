# Etap 1: Pobranie obrazu Visionect jako bazy
# Nazwa tego etapu to "visionect_base"
ARG BUILD_ARCH
FROM visionect/visionect-server-v3:${BUILD_ARCH_TAG} as visionect_base

# Etap 2: Budowanie finalnego dodatku
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Instalacja zależności (już bez curl!)
RUN apk add --no-cache postgresql postgresql-contrib redis fuse

# Magia wielostopniowego budowania: kopiujemy pliki bezpośrednio z pierwszego etapu
COPY --from=visionect_base / /

# Kopiowanie naszych skryptów s6-overlay
COPY rootfs/ /
RUN chmod +x -R /etc/s6-overlay/
