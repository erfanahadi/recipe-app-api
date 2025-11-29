FROM python:3.12-slim

WORKDIR /app


RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq-dev \
        libjpeg-dev \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' django-user && \
    mkdir -p /vol/web/media && \
    mkdir -p /vol/web/static && \
    chown -R django-user:django-user /vol && \
    chmod -R 755 /vol

COPY requirements.txt .


RUN pip install --upgrade pip && pip install -r requirements.txt

COPY ./app /app

RUN chown -R django-user:django-user /app

USER django-user

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
