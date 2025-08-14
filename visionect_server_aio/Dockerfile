# =================================================================
# OSTATECZNA, POPRAWNA WERSJA - 14 SIERPNIA 2025
# =================================================================

# Krok 1: Zadeklaruj WSZYSTKIE argumenty globalnie na samym początku.
# To jest klucz do rozwiązania problemu.
ARG BUILD_FROM
ARG BUILD_ARCH_TAG

# Etap 1: Pobranie obrazu Visionect jako bazy ("base stage").
# Używa on argumentu BUILD_ARCH_TAG.
FROM visionect/visionect-server-v3:${BUILD_ARCH_TAG} as visionect_base

# Etap 2: Budowanie finalnego dodatku.
# Ten etap używa argumentu BUILD_FROM.
FROM ${BUILD_FROM}

# Instalacja zależności w finalnym obrazie.
RUN apk add --no-cache postgresql postgresql-contrib redis fuse

# Magia wielostopniowego budowania: kopiujemy całą zawartość
# z pierwszego etapu ("visionect_base") do naszego finalnego obrazu.
COPY --from=visionect_base / /

# Kopiowanie naszych skryptów startowych (s6-overlay).
COPY rootfs/ /
RUN chmod +x -R /etc/s6-overlay/
