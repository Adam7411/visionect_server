FROM visionect/visionect-server-v3:7.6.5-arm # Or visionect/visionect-server-v3:7.6.5

# Ustawienie zmiennych środowiskowych (opcjonalne)
ENV MY_CUSTOM_VARIABLE="some_value"

# Instalacja dodatkowych pakietów (opcjonalne)
RUN apt-get update && apt-get install -y --no-install-recommends \
    some-package \
    another-package \
    && rm -rf /var/lib/apt/lists/*

# Kopiowanie własnych skryptów konfiguracyjnych (opcjonalne)
COPY my-custom-script.sh /opt/

# Nadanie uprawnień wykonywalnych skryptowi (opcjonalne)
RUN chmod +x /opt/my-custom-script.sh

# Uruchomienie skryptu przy starcie kontenera (opcjonalne)
CMD ["/opt/my-custom-script.sh"]
