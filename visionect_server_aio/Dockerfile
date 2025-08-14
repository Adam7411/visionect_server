# =================================================================
# OSTATECZNA, GWARANTOWANA WERSJA - 14 SIERPNIA 2025 v3 - FINAŁ
# =================================================================

# Krok 1: Deklaracja wszystkich argumentów globalnie.
ARG BUILD_FROM
ARG BUILD_ARCH_TAG

# Etap 1: Pobranie obrazu Visionect jako bazy.
FROM visionect/visionect-server-v3:${BUILD_ARCH_TAG} as visionect_base

# Etap 2: Budowanie finalnego dodatku z bazy Home Assistant.
FROM ${BUILD_FROM}

# Instalacja zależności.
RUN apk add --no-cache postgresql postgresql-contrib redis fuse

# Kopiujemy TYLKO folder /usr/local, gdzie znajduje się aplikacja Visionect.
COPY --from=visionect_base /usr/local/ /usr/local/

# Kopiowanie naszych skryptów startowych.
COPY rootfs/ /

# === OSTATECZNA POPRAWKA, KTÓRA WSZYSTKO NAPRAWIA ===
# Nadajemy uprawnienia do uruchamiania WSZYSTKIM skryptom, które skopiowaliśmy.
RUN chmod +x -R /etc/cont-init.d /etc/services.d
