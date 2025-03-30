FROM python:alpine

# Install necessary packages and clean up
RUN apk update && \
    apk add --no-cache \
    build-base \
    cmake \
    git \
    libffi-dev \
    openssl-dev \
    python3-dev \
    tzdata \
    mesa-gl \
    glib \
    libxext-dev \
    libxrender-dev

# Set the working directory
WORKDIR /usr/src/app

# Copy the requirements.txt file and install dependencies
COPY requirements.txt .
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-deps -r requirements.txt && \
    rm -rf ~/.cache/pip

# Copy the application code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Clean up unnecessary files
RUN find /usr/src/app -name '*.pyc' -delete && \
    find /usr/src/app -name '__pycache__' -delete

# Ensure the virtual environment is activated
ENV PATH="/usr/src/app/venv/bin:$PATH"
ENV PYTHONPATH="/usr/src/app"

# Expose the port the app runs on
EXPOSE 4000

# Command to run the application
CMD ["python", "Controller/ParentControlerInterface.py"]