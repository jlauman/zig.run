#!/usr/bin/env bash

sudo podman run \
    --name zig.run \
    --cap-add=NET_ADMIN \
    --volume ./log:/var/log/lighttpd \
    --volume ./web/doc:/home/web/doc \
    --volume ./web/src:/home/web/src \
    --publish "0.0.0.0:8080:80/tcp" \
    --rm -it \
    zig.run:latest
