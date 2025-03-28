FROM python:alpine AS base
ENV PYTHONUNBUFFERED=1
# Install build tools and dependencies; use apk’s --no-cache option to avoid local caching
RUN apk add --no-cache \
        build-base \
        cmake \
        git \
        libffi-dev \
        openssl-dev \
        python3-dev \
        tzdata && \
    rm -rf /var/cache/apk/*
WORKDIR /usr/src/app
COPY requirements.txt .

# Stage 2: Primary dependencies
FROM base AS primary-dependencies
# Create virtual environment and install primary packages using --no-cache-dir
RUN python3 -m venv /venv && \
    . /venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    rm -rf /root/.cache/pip

# Stage 3: NVIDIA dependencies
# Copy the venv from primary-dependencies to use the same environment
FROM base AS nvidia-dependencies
COPY --from=primary-dependencies /venv /venv
RUN . /venv/bin/activate && \
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
    rm -rf /root/.cache/pip

# Stage 4: Other dependencies
FROM primary-dependencies AS dependencies
# Merge NVIDIA dependencies into the environment
COPY --from=nvidia-dependencies /venv /venv
RUN . /venv/bin/activate && \
    pip install --no-cache-dir \
        triton pytz pyaes py-cpuinfo mpmath aniso8601 urllib3 tzdata typing-extensions tqdm \
        sympy six setuptools scipy pyyaml pyparsing pycparser pillow packaging networkx \
        kiwisolver Jinja2 itsdangerous idna fsspec fonttools filelock cycler contourpy \
        charset-normalizer certifi blinker python-dateutil matplotlib seaborn ultralytics-thop \
        torchvision && \
    pip check && \
    rm -rf /root/.cache/pip

# Stage 5: Build stage – copy application code and clean up temporary files and build tools
FROM dependencies AS build
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/
RUN find /usr/src/app -name '*.pyc' -delete && \
    find /usr/src/app -name '__pycache__' -delete && \
    apk del build-base cmake git libffi-dev openssl-dev python3-dev && \
    rm -rf /var/cache/apk/*

# Stage 6: Final production image
FROM python:alpine AS final
WORKDIR /usr/src/app
COPY --from=build /venv /venv
COPY --from=build /usr/src/app/Controller /usr/src/app/Controller
COPY --from=build /usr/src/app/Utils /usr/src/app/Utils
ENV PATH="/usr/src/app/venv/bin:$PATH"
EXPOSE 3000
CMD ["python", "Controller/ParentControlerInterface.py"]