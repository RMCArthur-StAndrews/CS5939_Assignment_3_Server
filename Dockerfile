# Stage 1: Build Stage with All Dependencies
FROM python:slim AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        libffi-dev \
        libssl-dev \
        python3-dev \
        tzdata && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /usr/src/app

# Copy your requirements file (assume it lists primary dependencies)
COPY requirements.txt .

# Create a virtual environment and install all dependencies in one layer.
# Include NVIDIA and other extra dependencies as needed.
RUN python3 -m venv /venv && \
    . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir \
        nvidia-cusparselt-cu12 \
        nvidia-nvtx-cu12 \
        nvidia-nvjitlink-cu12 \
        nvidia-nccl-cu12 \
        nvidia-curand-cu12 \
        nvidia-cufft-cu12 \
        nvidia-cuda-runtime-cu12 \
        nvidia-cuda-nvrtc-cu12 \
        nvidia-cuda-cupti-cu12 \
        nvidia-cublas-cu12 \
        nvidia-cusparse-cu12 \
        nvidia-cudnn-cu12 \
        nvidia-cusolver-cu12 && \
    pip install --no-cache-dir \
        triton \
        pytz \
        pyaes \
        py-cpuinfo \
        mpmath \
        aniso8601 \
        urllib3 \
        tzdata \
        typing-extensions \
        tqdm \
        sympy \
        six \
        setuptools \
        scipy \
        pyyaml \
        pyparsing \
        pycparser \
        pillow \
        packaging \
        networkx \
        kiwisolver \
        Jinja2 \
        itsdangerous \
        idna \
        fsspec \
        fonttools \
        filelock \
        cycler \
        contourpy \
        charset-normalizer \
        certifi \
        blinker \
        python-dateutil \
        matplotlib \
        seaborn \
        ultralytics-thop \
        torchvision && \
    pip check && \
    rm -rf ~/.cache/pip /tmp/* /var/tmp/*

# Copy application source code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Remove unnecessary files (e.g. Python caches)
RUN find . -name '*.pyc' -delete && \
    find . -name '__pycache__' -delete

# Remove build tools and extra dependencies to slim the image
RUN apt-get purge -y --auto-remove \
        build-essential \
        cmake \
        git \
        libffi-dev \
        libssl-dev \
        python3-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Stage 2: Final Stage
FROM python:slim

WORKDIR /usr/src/app

# Copy the virtual environment and application code from the build stage
COPY --from=build /venv /venv
COPY --from=build /usr/src/app/Controller /usr/src/app/Controller
COPY --from=build /usr/src/app/Utils /usr/src/app/Utils

# Ensure the virtual environment is used
ENV PATH="/venv/bin:$PATH"

EXPOSE 3000

# Command to run your application
CMD ["python", "Controller/ParentControlerInterface.py"]
