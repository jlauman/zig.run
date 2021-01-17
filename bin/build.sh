#!/usr/bin/env bash

# bin/play.sh

sudo podman build \
    --tag zig.run:latest \
    -f ./Dockerfile
