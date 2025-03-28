#!/bin/bash

# Remove all dangling images
docker builder prune

# Remove all unused images
docker image prune -a -f