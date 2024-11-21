#!/bin/bash

CONTAINER_NAME="demo"

# Prüfen, ob der Container läuft
if docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" | grep -q "${CONTAINER_NAME}"; then
    echo "Container '${CONTAINER_NAME}' läuft. Verbinde mit der Shell..."
    docker exec -it ${CONTAINER_NAME} /bin/bash
else
    # Prüfen, ob der Container existiert
    if docker ps -a --filter "name=${CONTAINER_NAME}" | grep -q "${CONTAINER_NAME}"; then
        echo "Container '${CONTAINER_NAME}' existiert, ist aber nicht aktiv. Starte und verbinde mit der Shell..."
        docker start ${CONTAINER_NAME} >/dev/null
        docker exec -it ${CONTAINER_NAME} /bin/bash
    else
        echo "Container '${CONTAINER_NAME}' existiert nicht. Starte neuen Container..."
        docker-compose up -d
        docker exec -it ${CONTAINER_NAME} /bin/bash
    fi
fi
