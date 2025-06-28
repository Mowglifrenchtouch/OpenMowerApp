#!/bin/bash

IMAGE=ghcr.io/mowglifrenchtouch/openmowerapp
CACHE=ghcr.io/mowglifrenchtouch/openmowerapp:buildcache

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag $IMAGE:latest \
  --cache-from=type=registry,ref=$CACHE \
  --cache-to=type=registry,ref=$CACHE,mode=max \
  --push .
