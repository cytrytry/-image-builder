#!/bin/bash

cd $(dirname $0)
docker build . -t novitalabs/2.8.0-cuda12.8-cudnn9-devel --build-arg BASE_IMAGE=pytorch/2.8.0-cuda12.8-cudnn9-devel
