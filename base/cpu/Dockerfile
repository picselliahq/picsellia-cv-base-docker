ARG PYTHON_VERSION=3.12
FROM ubuntu:24.04 AS base

ARG PYTHON_VERSION=3.12

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_HTTP_TIMEOUT=600 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y

RUN apt-get install --no-install-recommends -y \
    software-properties-common \
    curl \
    ca-certificates \
    build-essential

RUN add-apt-repository ppa:deadsnakes/ppa

RUN apt-get update && apt-get install --no-install-recommends -y \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv

RUN rm -f /usr/local/bin/python && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python

RUN curl -sS https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py && \
    python${PYTHON_VERSION} /tmp/get-pip.py --break-system-packages && \
    rm -f /tmp/get-pip.py && \
    rm -rf /var/lib/apt/lists/*

RUN python${PYTHON_VERSION} -m pip install --upgrade --break-system-packages pip setuptools && \
    python${PYTHON_VERSION} -m pip install --break-system-packages uv && \
    uv pip install --python=$(which python${PYTHON_VERSION}) --break-system-packages --no-cache-dir tabulate

COPY ./base /experiment

RUN ln -s /experiment/run.sh /usr/bin/run && \
    chmod +x /experiment/run.sh && \
    chown -R 42420:42420 /experiment
