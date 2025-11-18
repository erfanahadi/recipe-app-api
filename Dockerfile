# Base image سبک و کامل برای دستورات پایه
FROM python:3.12-slim

LABEL maintainer="erfan"

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy the Django app
COPY ./app /app

# Expose port
EXPOSE 8000

# Default command to run the server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
