#!/usr/bin/env bash
set -e

echo "Starting PostgreSQL..."
su - postgres -c "/usr/bin/initdb -D /data/postgres"
su - postgres -c "/usr/bin/pg_ctl -D /data/postgres -l /data/postgres.log start"

echo "Starting Redis..."
redis-server --daemonize yes

echo "Starting Visionect Server..."
/usr/local/bin/visionect-server
