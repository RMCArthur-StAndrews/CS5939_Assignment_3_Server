#!/bin/bash

# Stop and remove existing containers
docker-compose down

# Remove existing images
docker-compose rm -f

# Build and start the containers
docker-compose up --build -d

# Check if the services started successfully
if [ $? -eq 0 ]; then
  echo "Docker containers started successfully."
  echo "Webapp is accessible at http://localhost:3000"
  echo "API is accessible at http://localhost:5000"
else
  echo "Failed to start Docker containers."
fi

# Run the containers
docker-compose start