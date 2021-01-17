#!/usr/bin/env bash
set -e
# set -x

zig build-exe \
    -target x86_64-linux-gnu \
    -femit-bin=./web/bin/file.cgi \
    src/file.zig

cd web
echo '' | ./bin/file.cgi
cd ..

CONTAINER=$(sudo podman ps -q -f 'ancestor=localhost/zig.run')
if [[ ! -z "$CONTAINER" ]]; then
    sudo podman cp ./web/bin/file.cgi ${CONTAINER}:/home/web/bin/file.cgi
fi
