# Base image
FROM python:3.12-slim

# Working directory
WORKDIR /app

# Copy requirements first (leverages Docker layer caching)
COPY app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app/ .

# Expose application port
EXPOSE 5000

# Start the application
CMD ["python", "app.py"]
