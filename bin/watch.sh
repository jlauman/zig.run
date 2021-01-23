#!/usr/bin/env bash

SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P )
cd ${SCRIPT_PATH}/..


# sudo apt install inotify-tools

bin/compile_file_zig.sh
bin/compile_play_zig.sh

LAST_TIMESTAMP=$(date '+%Y%m%d%H%M%S')

inotifywait -m ./src -e modify |
    while read path action file; do
        TIMESTAMP=$(date '+%Y%m%d%H%M%S')
        DIFF=$(expr ${TIMESTAMP} - ${LAST_TIMESTAMP})
        # echo "DIFF=${DIFF}"
        if [[ "0" != "$DIFF" ]]; then
            printf "\n\n-------- file=${file} --------\n"
            if [[ "file.zig" == "$file" ]]; then bin/compile_file_zig.sh; fi
            if [[ "play.zig" == "$file" ]]; then bin/compile_play_zig.sh; fi
            if [[ "util.zig" == "$file" ]]; then 
                printf "\n\n-------- file=file.zig --------\n"
                bin/compile_file_zig.sh
                printf "\n\n-------- file=play.zig --------\n"
                bin/compile_play_zig.sh
            fi
            LAST_TIMESTAMP=${TIMESTAMP}
        fi
    done
