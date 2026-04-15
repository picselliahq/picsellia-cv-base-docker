ARG CUDA_VERSION=12.6.3
ARG CUDNN_VARIANT=cudnn
ARG UBUNTU_VERSION=24.04
FROM nvidia/cuda:${CUDA_VERSION}-${CUDNN_VARIANT}-runtime-ubuntu${UBUNTU_VERSION} AS base

ARG PYTHON_VERSION=3.12
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_HTTP_TIMEOUT=600 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade -y

RUN apt-get install --no-install-recommends -y \
    build-essential \
    software-properties-common \
    curl \
    ca-certificates

RUN add-apt-repository ppa:deadsnakes/ppa

RUN apt-get update && apt-get install --no-install-recommends -y \
    libpq-dev \
    libgtk2.0-dev \
    libgl1-mesa-dev \
    gcc \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv

RUN rm -f /usr/local/bin/python && \
    ln -s /usr/bin/python${PYTHON_VERSION} /usr/local/bin/python

RUN python${PYTHON_VERSION} -m ensurepip --upgrade && \
    rm -rf /var/lib/apt/lists/*

RUN python${PYTHON_VERSION} -m pip install --upgrade --break-system-packages pip setuptools && \
    python${PYTHON_VERSION} -m pip install --break-system-packages uv

ENV PATH="/usr/local/cuda/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/cuda/lib:/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

COPY ./base /experiment

RUN ln -s /experiment/run.sh /usr/bin/run && \
    chmod +x /experiment/run.sh && \
    chown -R 42420:42420 /experiment
