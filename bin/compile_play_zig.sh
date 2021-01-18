#!/usr/bin/env bash
set -e
# set -x

zig build-exe \
    -target x86_64-linux-gnu \
    -femit-bin=./web/bin/play.cgi \
    src/play.zig


cd web
echo '{"command":"run","file_name":"","source":"//@filename=main.zig\nconst std = @import(\"std\");\npub fn main() !void {\n  std.debug.print(\"hello world!\\n\", .{});\n}","output":""}' | ./bin/play.cgi
cd ..


CONTAINER=$(sudo podman ps -q -f 'ancestor=localhost/zig.run')
if [[ ! -z "$CONTAINER" ]]; then
    sudo podman cp ./web/bin/play.cgi ${CONTAINER}:/home/web/bin/play.cgi
fi
