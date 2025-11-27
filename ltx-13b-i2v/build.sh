#!/bin/bash

cd $(dirname $0)
docker build . -t novitalabs/comfyui:$(basename $(pwd)) "$@"
