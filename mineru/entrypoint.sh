#!/bin/bash
python3 -m vllm.entrypoints.openai.api_server --host 0.0.0.0 --port 8000 &

# 等待直到健康检查通过
echo "等待 vLLM Server 启动..."
for i in {1..6}; do
    if curl -f http://localhost:8000/health >/dev/null 2>&1; then
        echo "✅ vLLM Server 已就绪"
        break
    fi
    sleep 5
done

exec mineru-api --host 0.0.0.0 --port 30000