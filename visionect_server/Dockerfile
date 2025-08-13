FROM visionect/visionect-server-v3:7.6.5-arm

# Install Postgres & Redis
RUN apt-get update && \
    apt-get install -y postgresql redis-server && \
    rm -rf /var/lib/apt/lists/*

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
