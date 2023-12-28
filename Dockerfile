ARG PYTHON_VERSION

FROM python:$PYTHON_VERSION-slim-buster as builder

ARG POETRY_VERSION

WORKDIR /app

RUN python -m pip install --upgrade pip && \
    python -m pip install poetry==$POETRY_VERSION && \
    python -m venv /venv

COPY poetry.lock pyproject.toml ./

RUN . /venv/bin/activate && poetry install --without dev --no-root

COPY . .

RUN ./venv/bin/activate && poetry builder

FROM python:$PYTHON_VERSION-slim-buster

WORKDIR /app

COPY --from=builder /venv /venv
COPY --from=builder /app/dist .

RUN ./venv/bin/activate && pip install *.whl && \
    rm -f *.whl && \
    rm -f *.tar.gz