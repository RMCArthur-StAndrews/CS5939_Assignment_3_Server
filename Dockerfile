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
    tzdata \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin && \
    mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda-repo-ubuntu2004-11-8-local_11.8.0-520.61.05-1_amd64.deb && \
    dpkg -i cuda-repo-ubuntu2004-11-8-local_11.8.0-520.61.05-1_amd64.deb && \
    apt-key add /var/cuda-repo-ubuntu2004-11-8-local/7fa2af80.pub && \
    apt-get update && \
    apt-get -y install cuda

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
    find /usr/src/app -name '__pycache__' -delete && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Ensure the virtual environment is activated
ENV PATH="/usr/src/app/venv/bin:$PATH"
ENV PYTHONPATH="/usr/src/app"

# Expose the port the app runs on
EXPOSE 4000

# Command to run the application
CMD ["python", "Controller/ParentControlerInterface.py"]