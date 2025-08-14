#!/usr/bin/env bash
set -e

echo "Starting PostgreSQL..."
docker run -d --name visionect_postgres \
  -e POSTGRES_USER=visionect \
  -e POSTGRES_DB=koala \
  -e POSTGRES_PASSWORD=visionect \
  -v /data/pgdata:/var/lib/postgresql/data \
  postgres:latest

echo "Starting Redis..."
docker run -d --name visionect_redis redis:latest

echo "Starting Visionect Server..."
docker run -d --name visionect_server \
  --privileged \
  --device /dev/fuse:/dev/fuse \
  --cap-add MKNOD \
  --cap-add SYS_ADMIN \
  -e DB2_1_PORT_5432_TCP_ADDR=postgres \
  -e DB2_1_PORT_5432_TCP_USER=visionect \
  -e DB2_1_PORT_5432_TCP_PASS=visionect \
  -e DB2_1_PORT_5432_TCP_DB=koala \
  -e REDIS_ADDRESS=redis:6379 \
  -e VISIONECT_SERVER_ADDRESS=localhost \
  -p 8081:8081 \
  -p 11113:11113 \
  visionect/visionect-server-v3:7.6.5
