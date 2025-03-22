# Stage 1: Build the Node.js application
FROM node:20-alpine AS build

LABEL authors="RRHMc"

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json from the current directory
COPY package.json package-lock.json ./

# Clean npm cache and install npm globally
RUN npm cache clean --force && \
    npm install -g npm@11.2.0

# Install Node.js dependencies with the --legacy-peer-deps flag
RUN npm install --legacy-peer-deps

# Set the NODE_OPTIONS environment variable to use legacy OpenSSL providers
ENV NODE_OPTIONS=--openssl-legacy-provider

# Copy the rest of the application code from the current directory
COPY . .

# Install TypeScript and other dependencies
RUN npm install --legacy-peer-deps --save-dev typescript @types/node @types/react @types/react-dom && \
    npm install --legacy-peer-deps react react-dom react-scripts

# Build the application
RUN npm run build

# Clean up unnecessary files
RUN npm prune --production && \
    rm -rf /usr/src/app/node_modules/.cache && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /usr/src/app/node_modules/.bin && \
    rm -rf /usr/src/app/node_modules/typescript && \
    rm -rf /usr/src/app/node_modules/@types

# Stage 2: Create the final image
FROM node:20-slim

# Set the working directory
WORKDIR /usr/src/app

# Copy the build artifacts from the build stage
COPY --from=build /usr/src/app/build ./build
COPY --from=build /usr/src/app/package.json ./package.json
COPY --from=build /usr/src/app/node_modules ./node_modules

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]