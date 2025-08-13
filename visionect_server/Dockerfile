FROM visionect/visionect-server-v3:7.6.5

# Instalacja Postgres i Redis
RUN apt-get update && \
    apt-get install -y postgresql redis-server && \
    rm -rf /var/lib/apt/lists/*

# Kopiowanie skryptu uruchamiającego
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
