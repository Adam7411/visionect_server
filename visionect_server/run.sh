#!/usr/bin/with-contenv bashio
set -e

bashio::log.info "Starting Visionect Server Add-on..."

# Get configuration
POSTGRES_USER=$(bashio::config 'postgres_user')
POSTGRES_PASSWORD=$(bashio::config 'postgres_password')
POSTGRES_DB=$(bashio::config 'postgres_db')
REDIS_PORT=$(bashio::config 'redis_port')
IMAGE_TYPE=$(bashio::config 'image_type')

bashio::log.info "Configuration loaded: User=$POSTGRES_USER, DB=$POSTGRES_DB"

# Prepare directories
mkdir -p /var/lib/postgresql/data
mkdir -p /var/run/postgresql
chown -R postgres:postgres /var/lib/postgresql
chown -R postgres:postgres /var/run/postgresql

# Initialize PostgreSQL if needed
if [ ! -s /var/lib/postgresql/data/PG_VERSION ]; then
    bashio::log.info "Initializing PostgreSQL..."

    su-exec postgres initdb \
        --username="$POSTGRES_USER" \
        --pwfile=<(echo "$POSTGRES_PASSWORD") \
        -D /var/lib/postgresql/data \
        --auth-local=peer \
        --auth-host=md5

    # Configure PostgreSQL
    echo "listen_addresses = 'localhost'" >> /var/lib/postgresql/data/postgresql.conf
    echo "port = 5432" >> /var/lib/postgresql/data/postgresql.conf

    # Configure authentication
    echo "local   all             all                                     peer" > /var/lib/postgresql/data/pg_hba.conf
    echo "host    all             all             127.0.0.1/32            md5" >> /var/lib/postgresql/data/pg_hba.conf
    echo "host    all             all             ::1/128                 md5" >> /var/lib/postgresql/data/pg_hba.conf
fi

# Start PostgreSQL in background
bashio::log.info "Starting PostgreSQL..."
su-exec postgres postgres -D /var/lib/postgresql/data &
POSTGRES_PID=$!

# Wait for PostgreSQL
sleep 5
until su-exec postgres pg_isready -q; do
    bashio::log.info "Waiting for PostgreSQL..."
    sleep 2
done

# Create database if it doesn't exist
su-exec postgres createdb -O "$POSTGRES_USER" "$POSTGRES_DB" 2>/dev/null || true

# Start Redis in background
bashio::log.info "Starting Redis..."
redis-server --port "$REDIS_PORT" --bind 127.0.0.1 --daemonize yes

# Wait for Redis
until redis-cli -p "$REDIS_PORT" ping > /dev/null 2>&1; do
    bashio::log.info "Waiting for Redis..."
    sleep 2
done

# Set environment for Visionect
export DATABASE_URL="postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/$POSTGRES_DB"
export REDIS_URL="redis://localhost:$REDIS_PORT"
export VISIONECT_SERVER_ADDRESS="0.0.0.0"
export VISIONECT_SERVER_PORT="8081"

bashio::log.info "Starting Visionect Server..."

# Start Visionect Server
if [ -x /opt/visionect-server-v3/bin/koala ]; then
    cd /opt/visionect-server-v3
    exec ./bin/koala
else
    bashio::log.error "Visionect Server binary not found!"
    exit 1
fi
