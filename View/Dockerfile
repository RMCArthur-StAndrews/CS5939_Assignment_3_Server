# Stage 1: Build the Node.js application
FROM node:alpine AS build

LABEL authors="RRHMc"

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json from the current directory
COPY package.json package-lock.json ./

# Clean npm cache and install npm globally, then install dependencies
RUN npm cache clean --force && \
    npm install -g npm@11.2.0 && \
    npm install --legacy-peer-deps

# Set the NODE_OPTIONS environment variable to use legacy OpenSSL providers
ENV NODE_OPTIONS=--openssl-legacy-provider

# Copy the rest of the application code from the current directory
COPY . .

# Build the application
RUN npm run build

# Stage 2: Create the final image
FROM node:alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy the entire application from the build stage
COPY --from=build /usr/src/app /usr/src/app

# Install production dependencies
RUN npm install --only=production

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]