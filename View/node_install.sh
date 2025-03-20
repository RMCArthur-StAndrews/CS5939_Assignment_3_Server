#!/bin/bash

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install -y nodejs

# Initialize a new Node.js project (if not already initialized)
if [ ! -f package.json ]; then
  npm init -y
fi

# Install TypeScript and other dependencies
npm install --save-dev typescript @types/node @types/react @types/react-dom
npm install react react-dom