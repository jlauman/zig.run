#!/usr/bin/env bash
set -e
# set -x

SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P )
cd ${SCRIPT_PATH}/..


zig build-exe \
    -target x86_64-linux-gnu \
    -femit-bin=./web/bin/play.cgi \
    src/play.zig


cd web
echo '{"command":"run","file_name":"","source":"//@file_name=main.zig\nconst std = @import(\"std\");\npub fn main() !void {\n  std.debug.print(\"hello world!\\n\", .{});\n}","stderr":"","stdout":""}' | ./bin/play.cgi
cd ..


CONTAINER=$(sudo docker ps -q -f 'ancestor=localhost/zig.run')
if [[ ! -z "$CONTAINER" ]]; then
    sudo docker cp ./web/bin/play.cgi ${CONTAINER}:/home/web/bin/play.cgi
    sudo docker exec -u root ${CONTAINER} chown zig.zig /home/web/bin/play.cgi
    sudo docker exec -u root ${CONTAINER} chmod ug+s /home/web/bin/play.cgi
fi
