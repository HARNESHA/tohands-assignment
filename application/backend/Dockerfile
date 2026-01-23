FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app
ENV POETRY_VERSION=1.8.3
ENV POETRY_NO_INTERACTION=1
ENV POETRY_VIRTUALENVS_CREATE=false

WORKDIR /app

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"


COPY pyproject.toml poetry.lock* ./
RUN poetry install --no-root

COPY alembic.ini ./alembic.ini
COPY app ./app
COPY prestart.sh ./prestart.sh

# Fix Windows line endings
RUN sed -i 's/\r$//' ./prestart.sh && chmod +x ./prestart.sh

EXPOSE 8000

CMD ["bash", "-c", "cd /app && ./prestart.sh && uvicorn app.main:app --host 0.0.0.0 --port 8000"]
