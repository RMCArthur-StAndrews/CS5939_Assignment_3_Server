# Stage 1: Build the Node.js application
FROM node:16 AS build

LABEL authors=\"RRHMc\"

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json from the View directory
COPY View/package*.json ./

RUN npm cache clean --force

# Install Node.js dependencies with the --legacy-peer-deps flag
RUN npm install --legacy-peer-deps

# Copy the rest of the application code from the View directory
COPY View/ ./

# Install TypeScript and other dependencies
RUN npm install --legacy-peer-deps --save-dev typescript @types/node @types/react @types/react-dom
RUN npm install --legacy-peer-deps react react-dom

# Build the application
RUN npm run build