#!/bin/sh

for PID in $(pgrep play.cgi); do
    ELAPSED=$(ps -p ${PID} -o etime | grep ":" | xargs)
    ELAPSED="${ELAPSED:0:2}${ELAPSED:3:5}"
    if [ "$ELAPSED" -gt "0010" ]; then
        echo "$(date +"%FT%T") kill pid=${PID}, elapsed=${ELAPSED}" >> /var/log/playsafe.log
        kill ${PID}
        # else
        # echo "pid=${PID}, elapsed=${ELAPSED}"
    fi
done
