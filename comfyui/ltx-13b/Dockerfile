FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# install supervisord
RUN apt update -y && apt install -y supervisor && \
    mkdir -p /var/log/supervisord && \
    mkdir -p /opt/supervisor && \
    apt clean

# install jupyter
RUN pip install jupyter && \
    pip install nvitop && \
    pip cache purge
COPY jupyter/jupyter.sh   /opt/supervisor/jupyter.sh
COPY jupyter/jupyter.conf /etc/supervisor/conf.d/jupyter.conf

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    python3-venv \
    wget \
    curl \
    ffmpeg \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /opt

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /opt/ComfyUI

# Install Python dependencies
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
RUN pip3 install --no-cache-dir -r requirements.txt

# Install ComfyUI-LTXVideo
RUN mkdir -p custom_nodes && \
    cd custom_nodes && \
    git clone https://github.com/Lightricks/ComfyUI-LTXVideo.git && \
    cd ComfyUI-LTXVideo && \
    pip3 install --no-cache-dir -r requirements.txt

# Install ComfyUI-Manager for additional nodes
RUN cd /opt/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git && \
    cd ComfyUI-Manager && \
    pip3 install --no-cache-dir -r requirements.txt

# Install VideoHelperSuite (required for example workflows)
RUN cd /opt/ComfyUI/custom_nodes && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    cd ComfyUI-VideoHelperSuite && \
    pip3 install --no-cache-dir -r requirements.txt

# Create model directories
RUN mkdir -p /opt/ComfyUI/models/checkpoints \
    /opt/ComfyUI/models/clip_vision \
    /opt/ComfyUI/models/upscale_models \
    /opt/ComfyUI/models/t5_models

# Download LTXVideo model and T5 encoder
RUN wget -q https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltxv-13b-0.9.8-distilled.safetensors -O /opt/ComfyUI/models/checkpoints/ltxv-13b-0.9.8-distilled.safetensors && \
    mkdir -p /opt/ComfyUI/models/t5_models/google_t5-v1_1-xxl_encoderonly && \
    wget -q https://huggingface.co/mcmonkey/google_t5-v1_1-xxl_encoderonly/resolve/main/config.json -O /opt/ComfyUI/models/t5_models/google_t5-v1_1-xxl_encoderonly/config.json && \
    wget -q https://huggingface.co/mcmonkey/google_t5-v1_1-xxl_encoderonly/resolve/main/model.safetensors -O /opt/ComfyUI/models/t5_models/google_t5-v1_1-xxl_encoderonly/model.safetensors && \
    wget -q https://huggingface.co/mcmonkey/google_t5-v1_1-xxl_encoderonly/resolve/main/special_tokens_map.json -O /opt/ComfyUI/models/t5_models/google_t5-v1_1-xxl_encoderonly/special_tokens_map.json && \
    wget -q https://huggingface.co/mcmonkey/google_t5-v1_1-xxl_encoderonly/resolve/main/tokenizer_config.json -O /opt/ComfyUI/models/t5_models/google_t5-v1_1-xxl_encoderonly/tokenizer_config.json && \
    wget -q https://huggingface.co/mcmonkey/google_t5-v1_1-xxl_encoderonly/resolve/main/tokenizer.json -O /opt/ComfyUI/models/t5_models/google_t5-v1_1-xxl_encoderonly/tokenizer.json

# Install LTXVideo-Q8-Kernels for quantized model support
RUN pip3 install --no-cache-dir ltxvideo-q8-kernels

# Copy comfyui supervisor configuration
COPY comfyui/comfyui.sh         /opt/supervisor/comfyui.sh
COPY comfyui/comfyui.conf       /etc/supervisor/conf.d/comfyui.conf

# Create default workflows directory
RUN mkdir -p /opt/ComfyUI/user/default/workflows

# Copy LTXVideo default workflow
COPY comfyui/ltxvideo-flow-edit.json /opt/ComfyUI/user/default/workflows/ltxvideo-flow-edit.json

# Expose port
EXPOSE 8188

# Set up CMD to run supervisord
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]