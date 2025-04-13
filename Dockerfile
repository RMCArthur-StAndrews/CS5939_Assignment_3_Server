FROM python:slim

ENV DEBIAN_FRONTEND=noninteractive
ENV state=dev
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
    libxrender1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app
COPY requirements.txt .
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt  --extra-index-url https://download.pytorch.org/whl/cpu && \
    rm -rf ~/.cache/pip

COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

RUN find /usr/src/app -name '*.pyc' -delete && \
    find /usr/src/app -name '__pycache__' -delete && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH="/usr/src/app/venv/bin:$PATH"
ENV PYTHONPATH="/usr/src/app"

EXPOSE 5000

CMD ["python", "Controller/ParentControllerInterface.py", "--host=0.0.0.0 --port=5000"]