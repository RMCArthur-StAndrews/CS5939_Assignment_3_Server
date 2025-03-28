#!/bin/bash

# Remove all dangling images
docker builder prune -f

# Remove all unused images
docker image prune -a -f