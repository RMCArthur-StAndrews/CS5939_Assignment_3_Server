# Use a slim Python image
FROM python:3.9-slim-bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
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
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /usr/src/app

# Create a virtual environment and activate it
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip

# Install PyTorch and other dependencies
COPY requirements.txt .
RUN . venv/bin/activate && \
    pip install -r requirements.txt

# Copy the application code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["venv/bin/python", "app.py"]