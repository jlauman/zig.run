#!/bin/sh


iptables -t filter -I OUTPUT 1 -m state --state NEW -j DROP
# iptables -t filter -I OUTPUT 1 -m state --state NEW -j LOG --log-level warning \
#     --log-prefix "dropped new connection from local process" --log-uid


# cron hack to run play.cgi kill script every 12 seconds
cat << EOF >> /etc/crontabs/root
*/5     *       *       *       *       /bin/sh /app/play_clean.sh 
*       *       *       *       *       sleep 00; /bin/sh /app/play_safe.sh
*       *       *       *       *       sleep 12; /bin/sh /app/play_safe.sh
*       *       *       *       *       sleep 24; /bin/sh /app/play_safe.sh
*       *       *       *       *       sleep 36; /bin/sh /app/play_safe.sh
*       *       *       *       *       sleep 48; /bin/sh /app/play_safe.sh
EOF

/usr/sbin/crond -b -l 7 -L /var/log/cron.log


while true; do
    echo $(date -Iseconds)
    /usr/sbin/lighttpd -D -f /app/lighttpd.conf
done
