# Stage 1: Build the Python environment
FROM python:3.9-slim AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    libffi-dev \
    libssl-dev \
    python3-dev \
    tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /usr/src/app

# Copy the Python requirements file
COPY requirements.txt ./

# Create a virtual environment and install Python dependencies
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf ~/.cache/pip

# Stage 2: Create the final image
FROM python:3.9-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:/usr/src/app/venv/bin:${PATH}"

# Install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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