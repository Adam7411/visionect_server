# =================================================================
# OSTATECZNA, GWARANTOWANA, NAJPROSTSZA WERSJA
# =================================================================

# Etap 1: Pobranie obrazu Visionect jako bazy.
ARG BUILD_ARCH_TAG
FROM visionect/visionect-server-v3:${BUILD_ARCH_TAG} as visionect_base

# Etap 2: Budowanie finalnego dodatku z bazy Home Assistant.
# Używamy standardowej zmiennej BUILD_ARCH, aby wybrać właściwą bazę.
ARG BUILD_ARCH
FROM ghcr.io/home-assistant/${BUILD_ARCH}-base:latest

# Instalacja zależności w finalnym obrazie.
RUN apk add --no-cache postgresql postgresql-contrib redis fuse

# Kopiujemy TYLKO folder /usr/local, gdzie znajduje się aplikacja Visionect.
COPY --from=visionect_base /usr/local/ /usr/local/

# Kopiowanie naszych skryptów startowych.
COPY rootfs/ /
RUN chmod +x -R /etc/cont-init.d /etc/services.d
