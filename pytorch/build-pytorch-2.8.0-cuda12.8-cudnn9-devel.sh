#!/bin/bash

cd $(dirname $0)
docker build . -t image.paigpu.com/prod-gpucloudpublic/pytorch:2.2.2-cuda11.8-cudnn8-devel --build-arg BASE_IMAGE=pytorch/pytorch:2.2.2-cuda11.8-cudnn8-devel
