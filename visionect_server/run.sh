#!/usr/bin/env bash
set -e

POSTGRES_USER="${POSTGRES_USER:-visionect}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-visionect}"
POSTGRES_DB="${POSTGRES_DB:-koala}"
REDIS_PORT="${REDIS_PORT:-6379}"

echo "[Visionect Add-on] Starting initialization..."

# Ustaw zmienne środowiskowe dla Visionect
export DB2_1_PORT_5432_TCP_ADDR=localhost
export DB2_1_PORT_5432_TCP_USER="$POSTGRES_USER"
export DB2_1_PORT_5432_TCP_PASS="$POSTGRES_PASSWORD"
export DB2_1_PORT_5432_TCP_DB="$POSTGRES_DB"
export REDIS_ADDRESS=localhost:$REDIS_PORT
export VISIONECT_SERVER_ADDRESS=localhost

# Przygotowanie katalogu dla PostgreSQL
mkdir -p /var/lib/postgresql/data
chown -R postgres:postgres /var/lib/postgresql

# Inicjalizacja bazy, jeśli pusta
if [ ! -s /var/lib/postgresql/data/PG_VERSION ]; then
    echo "[Visionect Add-on] Initializing PostgreSQL..."
    su-exec postgres initdb --username="$POSTGRES_USER" --pwfile=<(echo "$POSTGRES_PASSWORD") -D /var/lib/postgresql/data
    
    # Konfiguracja PostgreSQL
    echo "host all all 127.0.0.1/32 md5" >> /var/lib/postgresql/data/pg_hba.conf
    echo "host all all ::1/128 md5" >> /var/lib/postgresql/data/pg_hba.conf
    echo "listen_addresses = 'localhost'" >> /var/lib/postgresql/data/postgresql.conf
    
    # Tymczasowe uruchomienie PostgreSQL do utworzenia bazy danych
    su-exec postgres postgres -D /var/lib/postgresql/data &
    PG_PID=$!
    
    # Czekaj na uruchomienie PostgreSQL
    sleep 5
    
    # Utwórz bazę danych
    su-exec postgres createdb -O "$POSTGRES_USER" "$POSTGRES_DB" 2>/dev/null || true
    
    # Zatrzymaj tymczasowy PostgreSQL
    kill $PG_PID
    wait $PG_PID 2>/dev/null || true
fi

echo "[Visionect Add-on] Initialization complete. Starting services via s6..."

# Przekaż zmienne środowiskowe do s6
echo "POSTGRES_USER=$POSTGRES_USER" > /var/run/s6/container_environment/POSTGRES_USER
echo "POSTGRES_PASSWORD=$POSTGRES_PASSWORD" > /var/run/s6/container_environment/POSTGRES_PASSWORD
echo "POSTGRES_DB=$POSTGRES_DB" > /var/run/s6/container_environment/POSTGRES_DB
echo "REDIS_PORT=$REDIS_PORT" > /var/run/s6/container_environment/REDIS_PORT

# Przekaż zmienne dla Visionect
echo "DB2_1_PORT_5432_TCP_ADDR=$DB2_1_PORT_5432_TCP_ADDR" > /var/run/s6/container_environment/DB2_1_PORT_5432_TCP_ADDR
echo "DB2_1_PORT_5432_TCP_USER=$DB2_1_PORT_5432_TCP_USER" > /var/run/s6/container_environment/DB2_1_PORT_5432_TCP_USER
echo "DB2_1_PORT_5432_TCP_PASS=$DB2_1_PORT_5432_TCP_PASS" > /var/run/s6/container_environment/DB2_1_PORT_5432_TCP_PASS
echo "DB2_1_PORT_5432_TCP_DB=$DB2_1_PORT_5432_TCP_DB" > /var/run/s6/container_environment/DB2_1_PORT_5432_TCP_DB
echo "REDIS_ADDRESS=$REDIS_ADDRESS" > /var/run/s6/container_environment/REDIS_ADDRESS
echo "VISIONECT_SERVER_ADDRESS=$VISIONECT_SERVER_ADDRESS" > /var/run/s6/container_environment/VISIONECT_SERVER_ADDRESS
