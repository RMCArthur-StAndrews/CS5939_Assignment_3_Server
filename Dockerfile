FROM python:slim

ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and clean up
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1

# Set the working directory
WORKDIR /usr/src/app

# Copy the requirements.txt file and install dependencies
COPY requirements.txt .
# Install required Python packages
RUN pip install -r requirements.txt

# Copy the application code
COPY Controller/ ./Controller/
COPY Utils/ ./Utils/

# Ensure the virtual environment is activated
ENV PATH="/usr/src/app/venv/bin:$PATH"
ENV PYTHONPATH="/usr/src/app"

# Expose the port the app runs on
EXPOSE 4000

# Command to run the application
CMD ["python", "Controller/ParentControlerInterface.py"]