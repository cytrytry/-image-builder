#!/bin/bash

cd $(dirname $0)
docker build . -t novitalabs/pytorch:2.1.2-cuda12.1-cudnn8-devel --build-arg BASE_IMAGE=pytorch/pytorch:2.1.2-cuda12.1-cudnn8-devel
