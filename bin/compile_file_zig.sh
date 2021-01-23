#!/usr/bin/env bash
set -e
# set -x

SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P )
cd ${SCRIPT_PATH}/..


zig build-exe \
    -target x86_64-linux-gnu \
    -femit-bin=./web/bin/file.cgi \
    src/file.zig


cd web
echo '' | ./bin/file.cgi
cd ..


CONTAINER=$(sudo docker ps -q -f 'ancestor=localhost/zig.run')
if [[ ! -z "$CONTAINER" ]]; then
    sudo docker cp ./web/bin/file.cgi ${CONTAINER}:/home/web/bin/file.cgi
fi
