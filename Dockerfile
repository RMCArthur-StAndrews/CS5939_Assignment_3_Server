# syntax=docker/dockerfile:1.2
FROM python:slim AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
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

WORKDIR /usr/src/app

COPY requirements.txt .

# Create virtual environment
RUN python -m venv /venv

# Use BuildKit cache mount to avoid caching pip files in the image
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

COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Clean up temporary files and remove build dependencies
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

# Final Stage
FROM python:slim

WORKDIR /usr/src/app

COPY --from=build /venv /venv
COPY --from=build /usr/src/app/Controller /usr/src/app/Controller
COPY --from=build /usr/src/app/Utils /usr/src/app/Utils

ENV PATH="/venv/bin:$PATH"

EXPOSE 3000

CMD ["python", "Controller/ParentControlerInterface.py"]
