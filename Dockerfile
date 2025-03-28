# Stage 1: Base stage
FROM python:slim AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and clean up
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libffi-dev \
    libssl-dev \
    python3-dev \
    tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the working directory
WORKDIR /usr/src/app

# Copy the requirements.txt file
COPY requirements.txt .

# Stage 2: Install primary dependencies
FROM base AS primary-dependencies

# Create a virtual environment, activate it, and install primary dependencies
RUN python3 -m venv venv && \
. venv/bin/activate && \
pip install --upgrade pip && \
pip install --no-cache-dir --no-deps -r requirements.txt && \
rm -rf ~/.cache/pip /tmp/* /var/tmp/*

# Stage 3: Install dependencies for the packages in requirements.txt
FROM primary-dependencies AS dependencies

# Install dependencies for the packages in requirements.txt
RUN . venv/bin/activate && \
pip install --no-cache-dir triton pytz pyaes py-cpuinfo nvidia-cusparselt-cu12 mpmath aniso8601 urllib3 tzdata typing-extensions tqdm sympy six setuptools scipy pyyaml pyparsing pycparser pillow packaging nvidia-nvtx-cu12 nvidia-nvjitlink-cu12 nvidia-nccl-cu12 nvidia-curand-cu12 nvidia-cufft-cu12 nvidia-cuda-runtime-cu12 nvidia-cuda-nvrtc-cu12 nvidia-cuda-cupti-cu12 nvidia-cublas-cu12 networkx kiwisolver Jinja2 itsdangerous idna fsspec fonttools filelock cycler contourpy charset-normalizer certifi blinker python-dateutil nvidia-cusparse-cu12 nvidia-cudnn-cu12 cffi nvidia-cusolver-cu12 matplotlib seaborn ultralytics-thop torchvision && \
pip check && \
rm -rf ~/.cache/pip /tmp/* /var/tmp/*

# Stage 4: Build stage
FROM dependencies AS build

# Copy the application code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Clean up unnecessary files
RUN find /usr/src/app -name '*.pyc' -delete && \
    find /usr/src/app -name '__pycache__' -delete && \
    apt-get remove --purge -y build-essential cmake git libffi-dev libssl-dev python3-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Stage 5: Final stage
FROM python:slim

# Set the working directory
WORKDIR /usr/src/app

# Copy the virtual environment and application code from the build stage
COPY --from=build /usr/src/app/venv /usr/src/app/venv
COPY --from=build /usr/src/app/Controller /usr/src/app/Controller
COPY --from=build /usr/src/app/Utils /usr/src/app/Utils

# Ensure the virtual environment is activated
ENV PATH="/usr/src/app/venv/bin:$PATH"