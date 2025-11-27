#!/bin/bash

if [ "$JUPYTER_PASSWORD" == "" ]; then
    JUPYTER_PASSWORD="1234567890"
fi

if [ "$JUPYTER_PREFERRED_DIR" == "" ]; then
    JUPYTER_PREFERRED_DIR="/root"
fi

if [ "$JUPYTER_PORT" == "" ]; then
    JUPYTER_PORT="8888"
fi

if [ "$JUPYTER_SHELL" == "" ]; then
    JUPYTER_SHELL="/bin/bash"
fi

exec jupyter lab \
    --allow-root \
    --no-browser \
    --port="$JUPYTER_PORT" \
    --ip=* \
    --FileContentsManager.delete_to_trash=False \
    --ServerApp.terminado_settings='{"shell_command":["'"$JUPYTER_SHELL"'"]}' \
    --ServerApp.token="$JUPYTER_PASSWORD" \
    --ServerApp.allow_origin=* \
    --ServerApp.preferred_dir="$JUPYTER_PREFERRED_DIR"
