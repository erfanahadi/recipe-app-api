# Base image سبک با Python 3.12
FROM python:3.12-alpine

LABEL maintainer="erfan"

# Set working directory
WORKDIR /app

# نصب ابزارهای مورد نیاز برای PostgreSQL و build
RUN apk add --no-cache \
        postgresql-client \
        gcc \
        musl-dev \
        postgresql-dev \
        libffi-dev \
        openssl-dev \
        build-base

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Copy Django app
COPY ./app /app

# Expose port
EXPOSE 8000

# Default command to run the server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
