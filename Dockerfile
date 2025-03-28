# Stage 1: Base stage
FROM python:alpine AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and clean up
RUN apk update && \
    apk add --no-cache \
    build-base \
    cmake \
    git \
    libffi-dev \
    openssl-dev \
    python3-dev \
    tzdata

# Set the working directory
WORKDIR /usr/src/app

# Copy the requirements.txt file
COPY requirements.txt .

# Stage 2: Install dependencies
FROM base AS dependencies

# Create a virtual environment, activate it, and install dependencies
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir --no-deps -r requirements.txt && \
    rm -rf ~/.cache/pip

# Stage 3: Build stage
FROM dependencies AS build

# Copy the application code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Clean up unnecessary files
RUN find /usr/src/app -name '*.pyc' -delete && \
    find /usr/src/app -name '__pycache__' -delete && \
    apk del build-base cmake git libffi-dev openssl-dev python3-dev && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Stage 4: Final stage
FROM python:alpine

# Set the working directory
WORKDIR /usr/src/app

# Copy the virtual environment and application code from the build stage
COPY --from=build /usr/src/app/venv /usr/src/app/venv
COPY --from=build /usr/src/app/Controller /usr/src/app/Controller
COPY --from=build /usr/src/app/Utils /usr/src/app/Utils

# Ensure the virtual environment is activated
ENV PATH="/usr/src/app/venv/bin:$PATH"

# Expose the port the app runs on
EXPOSE 3000

# Cleanup unnecessary libraries or assets
RUN rm -rf /usr/src/app/venv/lib/python3.*/site-packages/pip* \
    /usr/src/app/venv/lib/python3.*/site-packages/setuptools* \
    /usr/src/app/venv/lib/python3.*/site-packages/wheel* \
    /usr/src/app/venv/share && \
    rm -rf /tmp/* /var/tmp/* /usr/src/app/venv/include/* /usr/src/app/venv/share/* \
    /usr/src/app/venv/lib/python3.*/__pycache__ /usr/src/app/venv/lib/python3.*/test /usr/src/app/venv/lib/python3.*/tests && \
    rm -rf /usr/src/app/Controller /usr/src/app/Utils

# Command to run the application
CMD ["python", "Controller/ParentControlerInterface.py"]