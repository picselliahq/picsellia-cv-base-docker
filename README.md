# picsellia-cv-base-docker

Base Docker images used for Picsellia CV workloads:
- CPU jobs (Python runtime + logging entrypoint)
- GPU jobs (CUDA/CUDNN runtime + Python runtime + logging entrypoint)

## Build targets

### CPU images

The CPU image is built from `base/cpu/Dockerfile` and supports:
- Python `3.12`
- Python `3.13`
- Python `3.14`

Tag format:
- `picsellia/cpu:python<python_version>`
- Example: `picsellia/cpu:python3.14`

### GPU images

The GPU image is built from `base/cuda/Dockerfile` and supports Python `3.12` to `3.14` with multiple CUDA/CUDNN combinations.

Tag format:
- `picsellia/cuda:<cuda_version>-<cudnn_variant>-ubuntu<ubuntu_version>-python<python_version>`
- Example: `picsellia/cuda:12.6.3-cudnn9-ubuntu24.04-python3.14`

## Supported compatibility matrix

| Image type | Python version | CUDA version | CUDNN variant | Ubuntu base |
|---|---|---|---|---|
| CPU | 3.12 | - | - | bookworm (python base image) |
| CPU | 3.13 | - | - | bookworm (python base image) |
| CPU | 3.14 | - | - | bookworm (python base image) |
| GPU | 3.12 | 12.2.2 | cudnn8 | 22.04 |
| GPU | 3.12 | 12.4.1 | cudnn8 | 22.04 |
| GPU | 3.13 | 12.4.1 | cudnn8 | 22.04 |
| GPU | 3.12 | 12.6.3 | cudnn9 | 24.04 |
| GPU | 3.13 | 12.6.3 | cudnn9 | 24.04 |
| GPU | 3.14 | 12.6.3 | cudnn9 | 24.04 |

## Build and push

Use:

```bash
./scripts/build_and_push.sh
```

The script builds and pushes all matrix combinations above.