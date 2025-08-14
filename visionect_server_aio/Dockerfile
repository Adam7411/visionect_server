# =================================================================
# OSTATECZNA, GWARANTOWANA, TECHNICZNIE POPRAWNA WERSJA
# =================================================================

# Etap 1: Pobranie obrazu Visionect jako bazy ("base stage").
# Deklarujemy argument BEZPOŚREDNIO przed jego użyciem. To jest klucz do rozwiązania problemu.
ARG BUILD_ARCH_TAG
FROM visionect/visionect-server-v3:${BUILD_ARCH_TAG} as visionect_base

# Etap 2: Budowanie finalnego dodatku z bazy Home Assistant.
# Deklarujemy argument BEZPOŚREDNIO przed jego użyciem.
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Instalacja zależności w finalnym obrazie.
RUN apk add --no-cache postgresql postgresql-contrib redis fuse

# Kopiujemy TYLKO folder /usr/local, gdzie znajduje się aplikacja Visionect.
COPY --from=visionect_base /usr/local/ /usr/local/

# Kopiowanie naszych skryptów startowych.
COPY rootfs/ /
RUN chmod +x -R /etc/cont-init.d /etc/services.d
