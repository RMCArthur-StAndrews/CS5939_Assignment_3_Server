#!/bin/bash

# Remove all dangling images
docker image prune -f

# Remove all unused images
docker image prune -a -f