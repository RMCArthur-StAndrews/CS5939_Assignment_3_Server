# Stage 1: Build the Python environment
FROM python:3.9-alpine AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apk update && \
    apk add --no-cache \
    bash \
    build-base \
    gcc \
    g++ \
    libffi-dev \
    musl-dev \
    openssl-dev \
    python3-dev \
    tzdata && \
    rm -rf /var/cache/apk/*

# Set the working directory
WORKDIR /usr/src/app

# Copy the Python requirements file
COPY requirements.txt ./

# Create a virtual environment and install Python dependencies
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir numpy==1.21.0 && \
    pip install --no-cache-dir torch-1.8.0-cp39-cp39-linux_x86_64.whl && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf ~/.cache/pip

# Stage 2: Create the final image
FROM python:3.9-alpine

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/src/app/venv/bin:${PATH}"

# Install necessary packages
RUN apk update && \
    apk add --no-cache \
    tzdata && \
    rm -rf /var/cache/apk/*

# Set the working directory
WORKDIR /usr/src/app

# Copy the virtual environment from the build stage
COPY --from=build /usr/src/app/venv ./venv

# Copy the application code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["python", "app.py"]