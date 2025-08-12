#!/usr/bin/env bash
set -e

# Function to log messages
bashio() {
    case $1 in
        info)
            echo "[INFO] $2"
            ;;
        warning)
            echo "[WARNING] $2"
            ;;
        error)
            echo "[ERROR] $2"
            ;;
        *)
            echo "[$1] $2"
            ;;
    esac
}

# Read configuration from Home Assistant
CONFIG_PATH="/data/options.json"

if bashio::fs.file_exists "$CONFIG_PATH"; then
    POSTGRES_USER=$(bashio::config 'postgres_user' 2>/dev/null || echo "visionect")
    POSTGRES_PASSWORD=$(bashio::config 'postgres_password' 2>/dev/null || echo "visionect")
    POSTGRES_DB=$(bashio::config 'postgres_db' 2>/dev/null || echo "koala")
    REDIS_PORT=$(bashio::config 'redis_port' 2>/dev/null || echo "6379")
    IMAGE_TYPE=$(bashio::config 'image_type' 2>/dev/null || echo "auto")
else
    # Fallback values
    POSTGRES_USER="${POSTGRES_USER:-visionect}"
    POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-visionect}"
    POSTGRES_DB="${POSTGRES_DB:-koala}"
    REDIS_PORT="${REDIS_PORT:-6379}"
    IMAGE_TYPE="${IMAGE_TYPE:-auto}"
fi

bashio info "Starting Visionect Server Add-on..."
bashio info "Configuration: User=$POSTGRES_USER, DB=$POSTGRES_DB, Redis Port=$REDIS_PORT"

# Detect architecture and set image type
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        if [ "$IMAGE_TYPE" = "auto" ]; then
            VISIONECT_IMAGE="visionect/visionect-server-v3:7.6.5"
        elif [ "$IMAGE_TYPE" = "mini_pc" ]; then
            VISIONECT_IMAGE="visionect/visionect-server-v3:7.6.5"
        elif [ "$IMAGE_TYPE" = "raspberry_pi" ]; then
            VISIONECT_IMAGE="visionect/visionect-server-v3:7.6.5-arm"
        fi
        ;;
    armv7l|aarch64|arm64)
        if [ "$IMAGE_TYPE" = "auto" ] || [ "$IMAGE_TYPE" = "raspberry_pi" ]; then
            VISIONECT_IMAGE="visionect/visionect-server-v3:7.6.5-arm"
        elif [ "$IMAGE_TYPE" = "mini_pc" ]; then
            VISIONECT_IMAGE="visionect/visionect-server-v3:7.6.5"
        fi
        ;;
    *)
        bashio warning "Unknown architecture: $ARCH, using default image"
        VISIONECT_IMAGE="visionect/visionect-server-v3:7.6.5"
        ;;
esac

bashio info "Using Visionect image: $VISIONECT_IMAGE"

# Set environment variables for Visionect
export DB2_1_PORT_5432_TCP_ADDR=localhost
export DB2_1_PORT_5432_TCP_PORT=5432
export DB2_1_PORT_5432_TCP_USER="$POSTGRES_USER"
export DB2_1_PORT_5432_TCP_PASS="$POSTGRES_PASSWORD"
export DB2_1_PORT_5432_TCP_DB="$POSTGRES_DB"
export REDIS_ADDRESS="localhost:$REDIS_PORT"
export VISIONECT_SERVER_ADDRESS="0.0.0.0"
export VISIONECT_SERVER_PORT=8081

# Prepare PostgreSQL directory
mkdir -p /var/lib/postgresql/data
chown -R postgres:postgres /var/lib/postgresql

# Initialize database if empty
if [ ! -s /var/lib/postgresql/data/PG_VERSION ]; then
    bashio info "Initializing PostgreSQL database..."
    
    su-exec postgres initdb \
        --username="$POSTGRES_USER" \
        --pwfile=<(echo "$POSTGRES_PASSWORD") \
        -D /var/lib/postgresql/data \
        --auth-local=peer \
        --auth-host=md5
    
    # Configure PostgreSQL
    {
        echo "# Custom configuration"
        echo "listen_addresses = 'localhost'"
        echo "port = 5432"
        echo "max_connections = 100"
        echo "shared_buffers = 128MB"
        echo "log_destination = 'stderr'"
        echo "logging_collector = off"
        echo "log_statement = 'none'"
        echo "log_min_messages = warning"
    } >> /var/lib/postgresql/data/postgresql.conf
    
    # Configure authentication
    {
        echo "# Custom authentication"
        echo "local   all             all                                     peer"
        echo "host    all             all             127.0.0.1/32            md5"
        echo "host    all             all             ::1/128                 md5"
    } > /var/lib/postgresql/data/pg_hba.conf
    
    # Start PostgreSQL temporarily to create database
    bashio info "Creating database..."
    su-exec postgres postgres -D /var/lib/postgresql/data -p 5432 &
    PG_PID=$!
    
    # Wait for PostgreSQL to start
    sleep 10
    
    # Create database and user
    su-exec postgres psql -c "CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';" 2>/dev/null || true
    su-exec postgres createdb -O "$POSTGRES_USER" "$POSTGRES_DB" 2>/dev/null || true
    su-exec postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;" 2>/dev/null || true
    
    # Stop temporary PostgreSQL
    kill $PG_PID 2>/dev/null || true
    wait $PG_PID 2>/dev/null || true
    
    bashio info "Database initialization complete."
fi

# Create s6 environment variables
mkdir -p /var/run/s6/container_environment

# PostgreSQL variables
echo "$POSTGRES_USER" > /var/run/s6/container_environment/POSTGRES_USER
echo "$POSTGRES_PASSWORD" > /var/run/s6/container_environment/POSTGRES_PASSWORD
echo "$POSTGRES_DB" > /var/run/s6/container_environment/POSTGRES_DB

# Redis variables
echo "$REDIS_PORT" > /var/run/s6/container_environment/REDIS_PORT

# Visionect variables
echo "$DB2_1_PORT_5432_TCP_ADDR" > /var/run/s6/container_environment/DB2_1_PORT_5432_TCP_ADDR
echo "$DB2_1_PORT_5432_TCP_PORT" > /var/run/s6/container_environment/DB2_1_PORT_5432_TCP_PORT
echo "$DB2_1_PORT_5432_TCP_USER" > /var/run/s6/container_environment/DB2_1_PORT_5432_TCP_USER
echo "$DB2_1_PORT_5432_TCP_PASS" > /var/run/s6/container_environment/DB2_1_PORT_5432_TCP_PASS
echo "$DB2_1_PORT_5432_TCP_DB" > /var/run/s6/container_environment/DB2_1_PORT_5432_TCP_DB
echo "$REDIS_ADDRESS" > /var/run/s6/container_environment/REDIS_ADDRESS
echo "$VISIONECT_SERVER_ADDRESS" > /var/run/s6/container_environment/VISIONECT_SERVER_ADDRESS
echo "$VISIONECT_SERVER_PORT" > /var/run/s6/container_environment/VISIONECT_SERVER_PORT
echo "$VISIONECT_IMAGE" > /var/run/s6/container_environment/VISIONECT_IMAGE

bashio info "Starting services..."

# Start s6-overlay
exec /usr/bin/s6-svscan /etc/services.d
