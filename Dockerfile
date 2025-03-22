# Use a slim Python image
FROM python:slim

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
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /usr/src/app

# Copy the requirements.txt file
COPY requirements.txt .

# Create a virtual environment, activate it, and install dependencies
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    rm -rf ~/.cache/pip

# Copy the application code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["venv/bin/python", "app.py"]