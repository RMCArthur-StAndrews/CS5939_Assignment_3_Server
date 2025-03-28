FROM python:slim AS build

# Set non-interactive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Update system packages and install build dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
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

# Copy requirements for caching pip install steps
COPY requirements.txt .

# Create a Python virtual environment
RUN python -m venv /venv

# Install Python dependencies using BuildKit cache mount to avoid baking pip cache into image
RUN --mount=type=cache,target=/root/.cache/pip \
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
        nvidia-cusolver-cu12 \
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
    rm -rf ~/.cache/pip

# Copy application source code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Clean up Python cache and purge build dependencies to reduce image size
RUN find . -name '*.pyc' -delete && \
    find . -name '__pycache__' -delete && \
    apt-get purge -y --auto-remove \
        build-essential \
        cmake \
        git \
        libffi-dev \
        libssl-dev \
        python3-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#############################################
# Final Stage: Create a lean production image
#############################################
FROM python:slim

WORKDIR /usr/src/app

# Copy the updated virtual environment and source code from build stage
COPY --from=build /venv /venv
COPY --from=build /usr/src/app/Controller /usr/src/app/Controller
COPY --from=build /usr/src/app/Utils /usr/src/app/Utils

# Ensure the virtual environment’s binaries are in PATH
ENV PATH="/venv/bin:$PATH"

# Expose the port your application uses
EXPOSE 3000

# Run the production application
CMD ["python", "Controller/ParentControlerInterface.py"]