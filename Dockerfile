# Stage 1: Build stage
FROM python:slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools
RUN apt-get update && apt-get install -y build-essential gcc g++ make

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final stage
FROM python:slim

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy application code
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . /app

# Set the working directory
WORKDIR /app

# Expose the port the app runs on
EXPOSE 3000

# Command to run the application
CMD ["python", "Controller/ParentControlerInterface.py"]
