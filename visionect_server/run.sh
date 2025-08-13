#!/usr/bin/env bash
set -e

# Start PostgreSQL
service postgresql start
sudo -u postgres psql -c "CREATE USER visionect WITH PASSWORD 'visionect';" || true
sudo -u postgres psql -c "CREATE DATABASE koala OWNER visionect;" || true

# Start Redis
service redis-server start

# Start Visionect Server
exec /usr/bin/start-visionect-server
