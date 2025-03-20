# Stage 1: Build the Node.js application
FROM node:16 AS build

LABEL authors="RRHMc"

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

# Stage 2: Set up the Python environment
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND="noninteractive"

# Install necessary packages
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends locales tzdata python3 python3-venv python3-pip python3-dev openjdk-17-jdk-headless build-essential wget zip unzip curl git ca-certificates software-properties-common cmake pkg-config vim htop && \
    echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:${PATH}"

# Set the working directory
WORKDIR /usr/src/app

# Copy the built Node.js application from the previous stage
COPY --from=build /usr/src/app/build ./build

# Copy Python requirements file
COPY requirements.txt ./

# Upgrade pip and install Python dependencies
RUN pip3 install --user --upgrade --disable-pip-version-check pip && \
    pip3 install --user --no-cache-dir --disable-pip-version-check --root-user-action=ignore -r requirements.txt

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["python3", "app.py"]
ENTRYPOINT ["top", "-b"]