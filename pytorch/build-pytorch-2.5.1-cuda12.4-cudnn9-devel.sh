#!/bin/bash

cd $(dirname $0)
docker build . -t novitalabs/pytorch:2.5.1-cuda12.4-cudnn9-devel --build-arg BASE_IMAGE=pytorch/pytorch:2.5.1-cuda12.4-cudnn9-devel
