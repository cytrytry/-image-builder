#!/bin/bash

# --- Pre-flight Health Check ---
# Immediately check if a healthy VLM server is already running.
echo "Performing initial health check on http://localhost:8118/health..."
initial_status_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8118/health)

vlm_pid="" # Initialize vlm_pid as empty

if [ "$initial_status_code" -eq 200 ]; then
    echo "VLM server is already running and healthy. Skipping startup."
else
    echo "VLM server is not healthy or not running (status: $initial_status_code). Starting it now..."
    # Start the VLM server in the background
    /paddlex/py310_torch/bin/paddlex_genai_server --model_name PaddleOCR-VL-0.9B --host 0.0.0.0 --port 8118 --backend vllm &
    vlm_pid="$!"
    echo "VLM server started with PID: $vlm_pid"
fi

# --- Wait for Healthiness ---
# This function will either:
# 1. Return immediately if we already know the server is healthy.
# 2. Wait for the server we just started to become healthy.
wait_for_server_health() {
    # If the initial check was already 200, no need to wait.
    if [ "$initial_status_code" -eq 200 ]; then
        echo "Initial check was successful. Proceeding."
        return 0
    fi

    local max_attempts=120  # 10 minutes / 5 seconds = 120 attempts
    local attempt=0

    echo "Waiting for newly started VLM server to become healthy..."

    while [ $attempt -lt $max_attempts ]; do
        # Check if the process we started is still running
        if ! kill -0 $vlm_pid 2>/dev/null; then
            echo "Error: VLM server process (PID: $vlm_pid) died unexpectedly."
            exit 1
        fi

        # Check HTTP status code
        status_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8118/health)

        if [ "$status_code" -eq 200 ]; then
            echo "VLM server is now healthy (status code: $status_code)."
            return 0
        fi

        echo "Attempt $((attempt+1))/$max_attempts: Server not ready (status code: $status_code), retrying in 5 seconds..."
        sleep 5
        attempt=$((attempt+1))
    done

    echo "Error: Server did not become healthy within 10 minutes."
    return 1
}

# Run the health wait function
if ! wait_for_server_health; then
    # If the function failed, clean up the process if we started one
    if [ -n "$vlm_pid" ]; then
        echo "Killing VLM server process (PID: $vlm_pid) due to timeout."
        kill $vlm_pid 2>/dev/null
    fi
    exit 1
fi

# Set LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/cudnn/lib/


echo "Starting PaddleX server..."
# Start the PaddleX server (this will run in the foreground)
/paddlex/py310_torch/bin/paddlex --serve --pipeline /home/paddlex/PaddleOCR-VL.yaml

# --- Cleanup ---
# This part will only be reached if the PaddleX server stops
echo "PaddleX server has stopped."

# Clean up the VLM server if we started it
if [ -n "$vlm_pid" ]; then
    echo "Cleaning up VLM server process (PID: $vlm_pid)..."
    kill $vlm_pid 2>/dev/null
fi


