#!/usr/bin/env bash

SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P )
cd ${SCRIPT_PATH}/..


sudo docker run \
    --name zig.run \
    --detach --rm \
    --cap-add=NET_ADMIN \
    --publish "0.0.0.0:8080:80/tcp" \
    zig.run:local


    # --mount type=volume,source=web_tmp,target=/home/web/tmp \
