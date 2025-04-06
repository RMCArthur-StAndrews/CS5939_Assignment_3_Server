#!/bin/bash

docker stop --all
docker system prune -af
# Remove existing containers
docker rm -f webapp_container api_container

# Remove existing images
docker rmi -f webapp:latest api:latest

# Build the Docker image for the API
DOCKER_BUILDKIT=1
docker build -t api:latest -f Dockerfile . --squash

# Check if the API build was successful
if [ $? -eq 0 ]; then
  echo "API Docker image built successfully."

  # Run the API Docker container
  docker run -e state=prod -d -p 5000:5000 api:latest

  if [ $? -eq 0 ]; then
    echo "API Docker container started successfully."
    echo "API is accessible at http://localhost:5000"
  else
    echo "Failed to start API Docker container."
    exit 1
  fi

  # Navigate to the View directory and build the Docker image for the Webapp
  cd View
  docker build -t webapp:latest -f Dockerfile . --squash

  # Check if the Webapp build was successful
  if [ $? -eq 0 ]; then
    echo "Webapp Docker image built successfully."
    # Run the Webapp Docker container
    docker run -d -p 3000:3000 webapp:latest

    if [ $? -eq 0 ]; then
      echo "Webapp Docker container started successfully."
      echo "Webapp is accessible at http://localhost:8888"
    else
      echo "Failed to start Webapp Docker container."
      exit 1
    fi

    cd ..

    # Ensure clean.sh has execute permissions
    chmod +x clean.sh

    # Cleanup old Docker images after building the Webapp
    ./clean.sh
  else
    echo "Failed to build Webapp Docker image."
  fi
else
  echo "Failed to build API Docker image."
fi