#!/usr/bin/env bash
set -e

SCRIPT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P )
cd ${SCRIPT_PATH}/..

if [ "$#" -ne 1 ] || [ "${#1}" -ne "3" ]; then
    echo "renumber: requires 3 digit prefix argument"
    exit 1
fi

ACTION=SKIP
for NAME in $(ls -1 ./web/src); do
    PREFIX=${NAME:0:3}
    SUFFIX=${NAME:3}
    # echo "  PREFIX=\"${PREFIX}\", SUFFIX=\"${SUFFIX}\""
    if [ "$PREFIX" == "$1" ]; then ACTION=MOVE; fi
    if [ "$ACTION" == "MOVE" ] && [ "$PREFIX" != "999" ]; then
        NUMBER=$(expr ${PREFIX} + 1)
        echo "${NAME} --> ${NUMBER}${SUFFIX}" 
        git mv "./web/src/${NAME}" "./web/src/${NUMBER}${SUFFIX}"
    else
        echo "${NAME}" 
    fi
done
