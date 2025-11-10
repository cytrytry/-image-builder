#!/bin/bash
set -e

# 启动第一个服务
mineru-vllm-server --host 0.0.0.0 --port 30000 &

# 等待第一个服务启动
sleep 10

# 启动第二个服务，并等待
mineru-api --host 0.0.0.0 --port 8000