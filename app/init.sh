#!/bin/sh

iptables -t filter -I OUTPUT 1 -m state --state NEW -j DROP
# iptables -t filter -I OUTPUT 1 -m state --state NEW -j LOG --log-level warning \
#     --log-prefix "dropped new connection from local process" --log-uid

while true; do
    echo $(date -Iseconds)
    /usr/sbin/lighttpd -D -f /app/lighttpd.conf
done
