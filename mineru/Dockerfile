# Use DaoCloud mirrored vllm image for China region for gpu with Ampere architecture and above (Compute Capability>=8.0)
# Compute Capability version query (https://developer.nvidia.com/cuda-gpus)
FROM docker.m.daocloud.io/vllm/vllm-openai:v0.10.1.1

# Use the official vllm image
# FROM vllm/vllm-openai:v0.10.1.1

# Use DaoCloud mirrored vllm image for China region for gpu with Turing architecture and below (Compute Capability<8.0)
# FROM docker.m.daocloud.io/vllm/vllm-openai:v0.10.2

# Use the official vllm image
# FROM vllm/vllm-openai:v0.10.2

# Install libgl for opencv support & Noto fonts for Chinese characters
RUN apt-get update && \
    apt-get install -y \
        fonts-noto-core \
        fonts-noto-cjk \
        fontconfig \
        libgl1 && \
    fc-cache -fv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install mineru latest
RUN python3 -m pip install -U 'mineru[core]' -i https://mirrors.aliyun.com/pypi/simple --break-system-packages && \
    python3 -m pip cache purge

# Download models and update the configuration file
RUN /bin/bash -c "mineru-models-download -s modelscope -m all"

# Pre-download vLLM model: Qwen/Qwen3-0.6B
# Model source: https://huggingface.co/Qwen/Qwen3-0.6B
# This speeds up container startup by avoiding model download during runtime
# vLLM will use the cached model from ~/.cache/huggingface/hub/
RUN python3 -c "from huggingface_hub import snapshot_download; snapshot_download(repo_id='Qwen/Qwen3-0.6B', cache_dir='/root/.cache/huggingface')" || \
    echo "Warning: Model pre-download failed, will download at runtime"



ENTRYPOINT []