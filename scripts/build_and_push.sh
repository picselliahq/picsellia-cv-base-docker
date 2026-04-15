#!/bin/bash

set -euo pipefail

python_versions_cpu=("3.12" "3.13" "3.14")

# Format: "CUDA_VERSION CUDNN_VARIANT UBUNTU_VERSION SUPPORTED_PYTHON_VERSIONS"
gpu_configs=(
    "12.2.2 cudnn8 22.04 3.12"
    "12.4.1 cudnn 22.04 3.12 3.13"
    "12.6.3 cudnn 24.04 3.12 3.13 3.14"
)

start_index=0
list_only=false

usage() {
    echo "Usage: $0 [--start-index N] [--list]"
    echo
    echo "Options:"
    echo "  --start-index N   Resume build from global image index N (default: 0)"
    echo "  --list            Print all indexed combinations and exit"
    echo "  -h, --help        Show this help message"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --start-index)
            if [[ $# -lt 2 ]]; then
                echo "Error: --start-index requires a value"
                usage
                exit 1
            fi
            start_index="$2"
            shift 2
            ;;
        --list)
            list_only=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            usage
            exit 1
            ;;
    esac
done

if ! [[ "$start_index" =~ ^[0-9]+$ ]]; then
    echo "Error: --start-index must be a non-negative integer"
    exit 1
fi

build_index=0
total_images=0

for config in "${gpu_configs[@]}"; do
    read -r -a fields <<< "$config"
    python_versions=("${fields[@]:3}")
    total_images=$((total_images + ${#python_versions[@]}))
done
total_images=$((total_images + ${#python_versions_cpu[@]}))

echo "Total images in matrix: ${total_images}"
echo "Start index: ${start_index}"

for config in "${gpu_configs[@]}"; do
    read -r -a fields <<< "$config"
    cuda_version="${fields[0]}"
    cudnn_variant="${fields[1]}"
    ubuntu_version="${fields[2]}"
    python_versions=("${fields[@]:3}")

    for python_version in "${python_versions[@]}"; do
        image_tag="picsellia/cuda:${cuda_version}-${cudnn_variant}-ubuntu${ubuntu_version}-python${python_version}"
        image_label="[${build_index}/${total_images}]"

        if [[ "${list_only}" == true ]]; then
            echo "${build_index}|gpu|${image_tag}"
            build_index=$((build_index + 1))
            continue
        fi

        if (( build_index < start_index )); then
            echo "${image_label} Skipping (before start index): ${image_tag}"
            build_index=$((build_index + 1))
            continue
        fi

        echo "${image_label} Building image: ${image_tag}"
        docker build \
            --build-arg CUDA_VERSION="${cuda_version}" \
            --build-arg CUDNN_VARIANT="${cudnn_variant}" \
            --build-arg UBUNTU_VERSION="${ubuntu_version}" \
            --build-arg PYTHON_VERSION="${python_version}" \
            . -f base/cuda/Dockerfile -t "${image_tag}"
        docker push "${image_tag}"
        build_index=$((build_index + 1))
    done
done

for python_version in "${python_versions_cpu[@]}"; do
    image_tag="picsellia/cpu:python${python_version}"
    image_label="[${build_index}/${total_images}]"

    if [[ "${list_only}" == true ]]; then
        echo "${build_index}|cpu|${image_tag}"
        build_index=$((build_index + 1))
        continue
    fi

    if (( build_index < start_index )); then
        echo "${image_label} Skipping (before start index): ${image_tag}"
        build_index=$((build_index + 1))
        continue
    fi

    echo "${image_label} Building image: ${image_tag}"
    docker build --build-arg PYTHON_VERSION="${python_version}" . -f base/cpu/Dockerfile -t "${image_tag}"
    docker push "${image_tag}"
    build_index=$((build_index + 1))
done
