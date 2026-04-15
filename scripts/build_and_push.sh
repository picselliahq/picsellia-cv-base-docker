#!/bin/bash

set -euo pipefail

python_versions_cpu=("3.12" "3.13" "3.14")

# Format: "CUDA_VERSION CUDNN_VARIANT UBUNTU_VERSION SUPPORTED_PYTHON_VERSIONS"
gpu_configs=(
    "12.2.2 cudnn8 22.04 3.12"
    "12.4.1 cudnn8 22.04 3.12 3.13"
    "12.6.3 cudnn9 24.04 3.12 3.13 3.14"
)

for config in "${gpu_configs[@]}"; do
    read -r -a fields <<< "$config"
    cuda_version="${fields[0]}"
    cudnn_variant="${fields[1]}"
    ubuntu_version="${fields[2]}"
    python_versions=("${fields[@]:3}")

    for python_version in "${python_versions[@]}"; do
        image_tag="picsellia/cuda:${cuda_version}-${cudnn_variant}-ubuntu${ubuntu_version}-python${python_version}"
        echo "Building image: ${image_tag}"
        docker build \
            --build-arg CUDA_VERSION="${cuda_version}" \
            --build-arg CUDNN_VARIANT="${cudnn_variant}" \
            --build-arg UBUNTU_VERSION="${ubuntu_version}" \
            --build-arg PYTHON_VERSION="${python_version}" \
            . -f base/cuda/Dockerfile -t "${image_tag}"
        docker push "${image_tag}"
    done
done

for python_version in "${python_versions_cpu[@]}"; do
    image_tag="picsellia/cpu:python${python_version}"
    echo "Building image: ${image_tag}"
    docker build --build-arg PYTHON_VERSION="${python_version}" . -f base/cpu/Dockerfile -t "${image_tag}"
    docker push "${image_tag}"
done
