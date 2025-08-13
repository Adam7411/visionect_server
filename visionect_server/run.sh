#!/usr/bin/with-contenv bash

# Get the selected architecture
IMAGE_ARCHITECTURE=${IMAGE_ARCHITECTURE:-arm}

# Determine the Docker image based on the architecture
if [ "$IMAGE_ARCHITECTURE" == "arm" ]; then
  DOCKER_IMAGE="visionect/visionect-server-v3:7.6.5-arm"
elif [ "$IMAGE_ARCHITECTURE" == "x86" ]; then
  DOCKER_IMAGE="visionect/visionect-server-v3:7.6.5"
else
  echo "Unsupported architecture: $IMAGE_ARCHITECTURE" >&2
  exit 1
fi

# Check if the Docker image exists
if ! docker inspect --type=image "$DOCKER_IMAGE" > /dev/null 2>&1; then
  echo "Docker image '$DOCKER_IMAGE' not found.  Please ensure it's available on Docker Hub or a configured registry." >&2
  exit 1
fi

# Use configuration from Home Assistant
DB_HOST=${DB_HOST:-postgres}
DB_PORT=${DB_PORT:-5432}
DB_USER=${DB_USER:-visionect}
DB_PASSWORD=${DB_PASSWORD:-visionect}
DB_NAME=${DB_NAME:-koala}
REDIS_HOST=${REDIS_HOST:-redis}
REDIS_PORT=${REDIS_PORT:-6379}
VISIONECT_SERVER_ADDRESS=${VISIONECT_SERVER_ADDRESS:-localhost}


# Docker run command
docker run \
  --name=visionect_server \
  --privileged \
  --ulimit core=0 \
  --cap-add MKNOD \
  --cap-add SYS_ADMIN \
  --device /dev/fuse:/dev/fuse \
  --restart always \
  -p 8081:8081 \
  -p 11113:11113 \
  -e DB2_1_PORT_5432_TCP_ADDR=$DB_HOST \
  -e DB2_1_PORT_5432_TCP_PORT=$DB_PORT \
  -e DB2_1_PORT_5432_TCP_USER=$DB_USER \
  -e DB2_1_PORT_5432_TCP_PASS=$DB_PASSWORD \
  -e DB2_1_PORT_5432_TCP_DB=$DB_NAME \
  -e REDIS_ADDRESS=$REDIS_HOST:$REDIS_PORT \
  -e VISIONECT_SERVER_ADDRESS=$VISIONECT_SERVER_ADDRESS \
  -v /dev/shm:/dev/shm \
  $DOCKER_IMAGE
