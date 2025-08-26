# ComfyUI with LTXVideo 13B Docker Image

This Docker image provides a ready-to-use environment for running ComfyUI with LTXVideo 13B support.

## Features

- ComfyUI with LTXVideo 13B integration
- Support for both standard and quantized models
- Pre-installed essential custom nodes:
  - ComfyUI-LTXVideo
  - ComfyUI-Manager
  - ComfyUI-VideoHelperSuite

## Usage

### Building the Docker Image

```bash
docker build -t comfyui:ltx-13b .
```

### Running the Container

```bash
docker run --gpus all -p 8188:8188 -v /path/to/models:/opt/ComfyUI/models -v /path/to/outputs:/opt/ComfyUI/output comfyui:ltx-13b
```

Replace `/path/to/models` with the path to your models directory and `/path/to/outputs` with the path where you want to save the generated outputs.

## Included Models

This Docker image comes with the following pre-installed models:

1. **LTXVideo 13B 0.9.8 Distilled**
   - Pre-installed in `models/checkpoints`
   - From [Lightricks/LTX-Video](https://huggingface.co/Lightricks/LTX-Video)

2. **T5 Text Encoder: google_t5-v1_1-xxl_encoderonly**
   - Pre-installed in `models/t5_models`
   - From [mcmonkey/google_t5-v1_1-xxl_encoderonly](https://huggingface.co/mcmonkey/google_t5-v1_1-xxl_encoderonly)

## Additional Models (Optional)

You may want to add the following optional models:

1. **Latent Upscaling Models**
   - Place in `models/upscale_models`
   - Spatial upscaling and Temporal upscaling models

## Using Quantized Models

For quantized models, the image includes `ltxvideo-q8-kernels` package for optimal performance. Make sure to use the dedicated workflow for quantized models available in the Example Workflows section of the ComfyUI interface.

## Accessing ComfyUI

Once the container is running, access ComfyUI through your web browser:

```
http://localhost:8188
```

## Example Workflows

Example workflows for LTXVideo are available in the ComfyUI interface. You can load them directly from the ComfyUI-LTXVideo repository's example_workflows directory.
