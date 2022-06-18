#!/bin/bash
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo -e "Usage: $(basename $0) [OPTIONS] <version>"
    echo
    echo -e "Release the Docker image to Docker Hub"
    echo
    echo -e "Options:"
    echo -e "  -h, --help      Show this help"
    exit 0
fi

if [ -z "$1" ]; then
  >&2 echo Missing version
  exit 1
fi

VERSION=$1
IMAGE_NAME=antora-onbuild
HUB_USER=inrigo

docker manifest inspect $HUB_USER/$IMAGE_NAME:$VERSION > /dev/null 2>&1
if [ $? -eq 0 ] && [ "$VERSION" != "latest" ]; then
  >&2 echo The tag already exists $HUB_USER/$IMAGE_NAME:$VERSION
  exit 1
fi

docker tag $IMAGE_NAME $HUB_USER/$IMAGE_NAME:$VERSION
docker push $HUB_USER/$IMAGE_NAME:$VERSION
