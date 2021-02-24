#!/bin/sh
set -e
# set -x

CODE=$(cat $1 | base64 -w 0)
#CODE=$(openssl base64 -in src/hello.zig | tr -d '\n')
# echo "CODE=${CODE}"

curl -v http://127.0.0.1:8080/bin/play.cgi?base64=${CODE}
echo ""
