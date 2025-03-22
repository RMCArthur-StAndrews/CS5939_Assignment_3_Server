# Use a slim Python image
FROM python:3.9-alpine3.21

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
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