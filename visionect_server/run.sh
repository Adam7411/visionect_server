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

# Check if postgres and redis containers exist

# Function to check container status
check_container() {
  container_name="$1"
  if ! docker ps -a --format "{{.Names}}" | grep -q "$container_name"; then
    echo "Container '$container_name' is not running.  Please ensure the necessary dependencies (PostgreSQL, Redis) are running or adjust your addon configuration." >&2
    return 1
  else
    return 0
  fi
}

#Check if redis is accessible
if ! ping -c 1 redis &> /dev/null; then
  echo "Redis server not accessible.  Please ensure Redis is running or adjust your addon configuration." >&2
  exit 1
fi

#Check if postgres is accessible
if ! ping -c 1 postgres &> /dev/null; then
  echo "PostgreSQL server not accessible.  Please ensure PostgreSQL is running or adjust your addon configuration." >&2
  exit 1
fi


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
  -e DB2_1_PORT_5432_TCP_ADDR=postgres \
  -e DB2_1_PORT_5432_TCP_USER=visionect \
  -e DB2_1_PORT_5432_TCP_PASS=visionect \
  -e DB2_1_PORT_5432_TCP_DB=koala \
  -e REDIS_ADDRESS=redis:6379 \
  -e VISIONECT_SERVER_ADDRESS=localhost \
  -v /dev/shm:/dev/shm \
  $DOCKER_IMAGE
