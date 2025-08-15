#!/usr/bin/with-contenv bash
set -e

DATA_DIR="/data/postgres"

if [ -z "$(ls -A "$DATA_DIR" 2>/dev/null)" ]; then
  echo "Initializing PostgreSQL database..."
  mkdir -p "$DATA_DIR"
  chown -R postgres:postgres "$DATA_DIR"
  chmod 700 "$DATA_DIR"

  su - postgres -c "initdb -D '$DATA_DIR'"
  su - postgres -c "pg_ctl -D '$DATA_DIR' -o '-c listen_addresses=127.0.0.1' -w start"
  su - postgres -c "psql -v ON_ERROR_STOP=1 --username postgres <<-EOSQL
    CREATE USER visionect WITH PASSWORD 'visionect';
    CREATE DATABASE koala;
    GRANT ALL PRIVILEGES ON DATABASE koala TO visionect;
EOSQL"
  su - postgres -c "pg_ctl -D '$DATA_DIR' -m fast -w stop"
  echo "PostgreSQL initialization complete."
fi```

#### **5.2. `visionect_server_aio/rootfs/etc/services.d/postgres/run`**
```bash
#!/usr/bin/with-contenv bash
echo "Starting PostgreSQL server..."
exec su - postgres -c "postgres -D /data/postgres"
