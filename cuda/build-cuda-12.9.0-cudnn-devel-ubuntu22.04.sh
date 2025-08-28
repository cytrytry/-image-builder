#!/bin/bash

cd $(dirname $0)
docker build . -t novitalabs/cuda:12.9.0-cudnn-devel-ubuntu22.04 --build-arg BASE_IMAGE=nvidia/cuda:12.9.0-cudnn-devel-ubuntu22.04

