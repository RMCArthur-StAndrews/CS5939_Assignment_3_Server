#!/bin/bash

# Build the Docker image
docker build -t myapp:latest .

# Check if the build was successful
if [ $? -eq 0 ]; then
  echo "Docker image built successfully."

  # Run the Docker container
  docker run -d -p 3000:3000 --name myapp_container myapp:latest

  if [ $? -eq 0 ]; then
    echo "Docker container started successfully."
  else
    echo "Failed to start Docker container."
  fi
else
  echo "Failed to build Docker image."
fi