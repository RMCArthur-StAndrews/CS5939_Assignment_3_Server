#!/bin/bash
docker stop --all
docker system prune -af

docker rm -f webapp_container api_container

docker rmi -f webapp:latest api:latest
DOCKER_BUILDKIT=1
docker build -t api:latest -f Dockerfile . --squash
if [ $? -eq 0 ]; then
  echo "API Docker image built successfully."

  docker run -e state=prod -d -p 5000:5000 api:latest

  if [ $? -eq 0 ]; then
    echo "API Docker container started successfully."
    echo "API is accessible at http://localhost:5000"
  else
    echo "Failed to start API Docker container."
    exit 1
  fi

  cd View
  docker build -t webapp:latest -f Dockerfile . --squash

  if [ $? -eq 0 ]; then
    echo "Webapp Docker image built successfully."
    docker run -d -p 3000:3000 webapp:latest

    if [ $? -eq 0 ]; then
      echo "Webapp Docker container started successfully."
      echo "Webapp is accessible at http://localhost:8888"
    else
      echo "Failed to start Webapp Docker container."
      exit 1
    fi

    cd ..
    chmod +x clean.sh
    ./clean.sh
  else
    echo "Failed to build Webapp Docker image."
  fi
else
  echo "Failed to build API Docker image."
fi