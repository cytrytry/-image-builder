#!/bin/bash

cd $(dirname $0)
docker build . -t novitalabs/cuda:12.3.2-cudnn9-devel-ubuntu22.04 --build-arg BASE_IMAGE=nvidia/cuda:12.3.2-cudnn9-devel-ubuntu22.04
