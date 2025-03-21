FROM python:3.9-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update --yes && \
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends locales tzdata python3 python3-venv python3-pip python3-dev build-essential wget zip unzip curl git ca-certificates software-properties-common cmake pkg-config vim htop && \
    echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install --yes nodejs && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:${PATH}"

# Set the working directory
WORKDIR /usr/src/app

# Clear the current folder
RUN rm -rf /usr/src/app/*

# Copy the Python requirements file
COPY requirements.txt ./

# Upgrade pip and install Python dependencies
RUN pip3 install --user --upgrade --disable-pip-version-check pip && \
    pip3 install --user --no-cache-dir --disable-pip-version-check --root-user-action=ignore -r requirements.txt

# Copy the Controller and Utils folders
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["python3", "app.py"]