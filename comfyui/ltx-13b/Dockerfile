FROM pytorch/pytorch:2.8.0-cuda12.8-cudnn9-devel

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# install supervisord
RUN apt update -y && apt install -y supervisor && \
    mkdir -p /var/log/supervisord && \
    mkdir -p /opt/supervisor && \
    apt clean

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
    aria2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /opt

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /opt/ComfyUI


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

# install jupyter
RUN pip3 install jupyterlab && \
    pip3 install nvitop && \
    pip3 cache purge
COPY jupyter/jupyter.sh   /opt/supervisor/jupyter.sh
COPY jupyter/jupyter.conf /etc/supervisor/conf.d/jupyter.conf

# Install VideoHelperSuite (required for example workflows)
RUN cd /opt/ComfyUI/custom_nodes && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    cd ComfyUI-VideoHelperSuite && \
    pip3 install --no-cache-dir -r requirements.txt

# Install ComfyUI-Custom-Scripts (provides ImageResizeKJ node)
RUN cd /opt/ComfyUI/custom_nodes && \
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    cd ComfyUI-Custom-Scripts && \
    pip3 install --no-cache-dir -r requirements.txt || echo "No requirements.txt found"

# Install ComfyUI-KJNodes (provides ImageResizeKJ node)
RUN cd /opt/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
    cd ComfyUI-KJNodes && \
    pip3 install --no-cache-dir -r requirements.txt || echo "No requirements.txt found"

# Create model directories
RUN mkdir -p /opt/ComfyUI/models/checkpoints

# Create clip directory
RUN mkdir -p /opt/ComfyUI/models/clip

# Download LTX Video 13B FP8 Quantized model (from NextDiffusion tutorial)
RUN cd /opt/ComfyUI/models/checkpoints && \
    aria2c -k 1M -s 10 -x 10 --retry-wait=10 --max-tries=5 \
    https://huggingface.co/Kijai/LTXV/resolve/main/ltxv-13b-0.9.7-dev_fp8_e4m3fn.safetensors \
    -o ltxv-13b-0.9.7-dev_fp8_e4m3fn.safetensors

# Download T5 CLIP model for LTX Video (from NextDiffusion tutorial)
RUN cd /opt/ComfyUI/models/clip && \
    aria2c -k 1M -s 10 -x 10 --retry-wait=10 --max-tries=5 \
    https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors \
    -o t5xxl_fp8_e4m3fn.safetensors

# Download spatial upscaler (used in workflow)
RUN mkdir -p /opt/ComfyUI/models/upscale_models && \
    cd /opt/ComfyUI/models/upscale_models && \
    aria2c -k 1M -s 10 -x 10 --retry-wait=10 --max-tries=5 \
    https://huggingface.co/Lightricks/LTX-Video/resolve/main/ltxv-spatial-upscaler-0.9.7.safetensors \
    -o ltxv-spatial-upscaler-0.9.8.safetensors

# Install additional dependencies for LTX Video 13B 0.9.7
RUN pip3 install --no-cache-dir einops transformers

# Install required dependencies for LTX-Video-Q8-Kernels
RUN pip3 install --no-cache-dir packaging wheel ninja setuptools typing-extensions

# Skip LTX-Video-Q8-Kernels installation as it requires actual NVIDIA GPU for compilation
# The kernels will need to be installed when deployed to a machine with GPU
RUN echo "Skipping LTX-Video-Q8-Kernels installation - will be installed on deployment to GPU machine"

# Create a placeholder directory for LTX-Video-Q8-Kernels
# This is to avoid import errors when running ComfyUI
RUN mkdir -p /opt/conda/lib/python3.11/site-packages/q8_kernels_cuda

# Note: The models from NextDiffusion tutorial should be publicly available without authentication

# Create a startup script that installs LTX-Video-Q8-Kernels if GPU is available
RUN echo '#!/bin/bash\n\
# Check if NVIDIA GPU is available\n\
if [ -c /dev/nvidia0 ] || [ -c /dev/nvidia-uvm ]; then\n\
  echo "NVIDIA GPU detected, installing LTX-Video-Q8-Kernels..."\n\
  cd /tmp && \\\n\
  git clone https://github.com/Lightricks/LTX-Video-Q8-Kernels.git && \\\n\
  cd LTX-Video-Q8-Kernels && \\\n\
  pip3 install --no-build-isolation -e .\n\
else\n\
  echo "No NVIDIA GPU detected, skipping LTX-Video-Q8-Kernels installation"\n\
fi\n\
\n\
# Start ComfyUI\n\
cd /opt/ComfyUI && python3 main.py --listen 0.0.0.0\n\
' > /opt/supervisor/comfyui.sh && chmod +x /opt/supervisor/comfyui.sh

# Copy comfyui supervisor configuration
COPY comfyui/comfyui.conf       /etc/supervisor/conf.d/comfyui.conf

# Create default workflows directory
RUN mkdir -p /opt/ComfyUI/user/default/workflows

# Copy workflow file directly
COPY comfyui/ltxv-13b-i2v-base-fp8.json /opt/ComfyUI/user/default/workflows/

# Expose port
EXPOSE 8188

# Set up CMD to run supervisord
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]