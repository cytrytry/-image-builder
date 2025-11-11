#!/bin/bash
set -e


mineru-vllm-server --host 0.0.0.0 --port 30000 &

sleep 10

mineru-api --host 0.0.0.0 --port 8000