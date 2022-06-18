#!/bin/bash
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo -e "Usage: $(basename $0) [OPTIONS]"
    echo
    echo -e "Builds the Docker image"
    echo
    echo -e "Options:"
    echo -e "      --no-cache  Removes local images and containers and force full rebuild"
    echo -e "  -h, --help      Show this help"
    exit 0
fi

IMAGE_NAME=antora-onbuild
if [ "$1" == "--no-cache" ]; then
  docker kill $(docker ps -q -f "ancestor=$IMAGE_NAME") > /dev/null 2>&1
  docker rmi $IMAGE_NAME
  docker build --no-cache . -t $IMAGE_NAME
else
  docker build . -t $IMAGE_NAME
fi
