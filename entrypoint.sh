#!/bin/sh
set -e

if [[ ! -d /var/log/squid/00 ]]; then
  echo "Initializing cache..."
  /usr/sbin/squid -N -f /etc/squid/squid.conf -z
fi

if [ "$(basename $1)" == "squid" ]; then
    trap 'rm -f /var/log/squid/access.log' EXIT SIGINT SIGTERM
    su -s /bin/sh squid -c 'mkfifo /var/log/squid/access.log'
    cat /var/log/squid/access.log &
    $@
else
    exec "$@"
fi
