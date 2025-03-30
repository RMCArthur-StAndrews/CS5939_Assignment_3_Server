# Stage 1: Base stage
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND="noninteractive"

# Install necessary packages and clean up
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    locales \
    tzdata \
    python3 \
    python3-venv \
    python3-pip \
    python3-dev \
    openjdk-17-jdk-headless \
    build-essential \
    wget \
    zip \
    unzip \
    curl \
    git \
    ca-certificates \
    software-properties-common \
    cmake \
    pkg-config \
    vim \
    htop && \
    echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:${PATH}"

# Set the working directory
WORKDIR /usr/src/app

# Copy the requirements.txt file
COPY requirements.txt ./

# Upgrade pip and install dependencies
RUN pip3 install --user --upgrade --disable-pip-version-check pip && \
    pip3 install --user --no-cache-dir --disable-pip-version-check --root-user-action=ignore -r requirements.txt

# Stage 2: Build stage
FROM base AS build

# Copy the application code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Clean up unnecessary files
RUN find /usr/src/app -name '*.pyc' -delete && \
    find /usr/src/app -name '__pycache__' -delete && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Stage 3: Final stage
FROM ubuntu:22.04

# Install OpenCV dependencies in the final stage
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /usr/src/app

# Copy the virtual environment and application code from the build stage
COPY --from=build /usr/src/app/venv /usr/src/app/venv
COPY --from=build /usr/src/app/Controller /usr/src/app/Controller
COPY --from=build /usr/src/app/Utils /usr/src/app/Utils

# Ensure the virtual environment is activated
ENV PATH="/usr/src/app/venv/bin:$PATH"
ENV PYTHONPATH="/usr/src/app"

# Expose the port the app runs on
EXPOSE 4000

# Command to run the application
CMD ["python3", "Controller/ParentControlerInterface.py"]