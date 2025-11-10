#!/bin/bash

# MinerU Multi-Service Startup Script
# Runs both mineru-vllm-server and mineru-api in the same container

set -e

# --- Configuration Variables ---
VLLM_HOST="0.0.0.0"
VLLM_PORT="30000"
API_HOST="0.0.0.0"
API_PORT="8000"
HEALTH_CHECK_TIMEOUT=120  # Health check timeout (seconds)
SLEEP_INTERVAL=5         # Check interval (seconds)

# --- CUDA/Flash-Attention Configuration ---
# Disable flash-attention to avoid CUDA errors on non-Hopper GPUs
# Try multiple environment variables to ensure compatibility
export VLLM_USE_TRITON_FLASH_ATTENTION=0
export VLLM_USE_FLASH_ATTENTION=0
export VLLM_ATTENTION_BACKEND=XFORMERS

# --- Logging Functions ---
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_info() {
    log "INFO: $1"
}

log_warn() {
    log "WARN: $1"
}

log_error() {
    log "ERROR: $1"
}

log_success() {
    log "SUCCESS: $1"
}

# --- Health Check Function ---
check_vllm_health() {
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${VLLM_PORT}/health" 2>/dev/null || echo "000")
    echo "$status_code"
}

# --- Signal Handler Function ---
cleanup() {
    log_info "Received stop signal, gracefully shutting down services..."
    
    # Stop API service (foreground process, will exit naturally)
    if [ -n "$API_PID" ] && kill -0 "$API_PID" 2>/dev/null; then
        log_info "Sending stop signal to mineru-api..."
        kill -TERM "$API_PID" 2>/dev/null
    fi
    
    # Stop VLLM service (if we started it)
    if [ -n "$VLLM_PID" ] && kill -0 "$VLLM_PID" 2>/dev/null; then
        log_info "Stopping mineru-vllm-server..."
        kill -TERM "$VLLM_PID" 2>/dev/null
        # Wait for process to finish
        wait "$VLLM_PID" 2>/dev/null || true
    fi
    
    log_success "All services have been stopped"
    exit 0
}

# Register signal handlers
trap cleanup SIGTERM SIGINT

# --- Pre-flight Health Check ---
log_info "Checking mineru-vllm-server health status..."
initial_health=$(check_vllm_health)
VLLM_PID=""  # Initialize variable

if [ "$initial_health" -eq 200 ]; then
    log_success "mineru-vllm-server is already running and healthy (HTTP $initial_health)"
else
    log_info "mineru-vllm-server is not running or unhealthy (HTTP $initial_health), starting now..."
    
    # Start mineru-vllm-server (background process)
    # Disable flash-attention to avoid CUDA errors on non-Hopper GPUs
    mineru-vllm-server --host "$VLLM_HOST" --port "$VLLM_PORT" &
    VLLM_PID=$!
    log_info "mineru-vllm-server started with PID: $VLLM_PID"
    
    # --- Wait for VLLM Service to be Ready ---
    log_info "Waiting for mineru-vllm-server to become ready..."
    attempts=0
    max_attempts=$((HEALTH_CHECK_TIMEOUT / SLEEP_INTERVAL))
    
    while [ $attempts -lt $max_attempts ]; do
        # Check if process is still alive
        if ! kill -0 "$VLLM_PID" 2>/dev/null; then
            log_error "mineru-vllm-server process died unexpectedly"
            exit 1
        fi
        
        # Check health status
        current_health=$(check_vllm_health)
        
        if [ "$current_health" -eq 200 ]; then
            log_success "mineru-vllm-server is now ready (HTTP $current_health)"
            break
        fi
        
        attempts=$((attempts + 1))
        if [ $attempts -eq $max_attempts ]; then
            log_error "mineru-vllm-server did not become ready within ${HEALTH_CHECK_TIMEOUT} seconds"
            cleanup
            exit 1
        fi
        
        log_info "Attempt $attempts/$max_attempts: Service not ready yet (HTTP $current_health), retrying in ${SLEEP_INTERVAL} seconds..."
        sleep $SLEEP_INTERVAL
    done
fi

# --- Set Environment Variables ---
export MINERU_MODEL_SOURCE=local
log_info "Environment variable set: MINERU_MODEL_SOURCE=$MINERU_MODEL_SOURCE"

# --- Start mineru-api (Foreground Process) ---
log_info "Starting mineru-api service..."
log_info "VLLM Service Endpoint: http://${VLLM_HOST}:${VLLM_PORT}"
log_info "API Service Endpoint: http://${API_HOST}:${API_PORT}"

mineru-api --host "$API_HOST" --port "$API_PORT" &
API_PID=$!
log_info "mineru-api started with PID: $API_PID"

# --- Wait for API Service to Exit ---
log_info "All services started successfully, waiting for foreground service to run..."
log_info "Use Ctrl+C or send stop signal to shutdown services"

# Wait for API process (foreground process)
wait "$API_PID" 2>/dev/null || true

# --- Cleanup Phase ---
log_info "mineru-api has stopped, starting cleanup..."
cleanup