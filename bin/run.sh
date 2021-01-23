#!/usr/bin/env bash

SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P )
cd ${SCRIPT_PATH}/..


sudo docker run \
    --name zig.run \
    --cap-add=NET_ADMIN \
    --volume ./log:/var/log/lighttpd \
    --volume ./web/doc:/home/web/doc \
    --volume ./web/src:/home/web/src \
    --publish "0.0.0.0:8080:80/tcp" \
    --rm -it \
    zig.run:local


    # --mount type=volume,source=web_tmp,target=/home/web/tmp \
