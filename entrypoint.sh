#!/bin/sh
#
# Refs:
#    * https://wiki.squid-cache.org/Features/DynamicSslCert
#    * http://marek.helion.pl/install/squid.html

set -e
touch /etc/squid/nobump-sites.txt

if [ ! -f "/etc/squid/ssl_cert/squid.pem" ];
then
    # https://wiki.squid-cache.org/Features/DynamicSslCert
    subject="/C=${CERT_C:-BR}"
    subject="$subject/ST=${CERT_ST:-SP}"
    subject="$subject/L=${CERT_L:-São Roque}"
    subject="$subject/O=${CERT_O:-FM}"
    subject="$subject/OU=${CERT_OU:-FM}"
    subject="$subject/CN=${CERT_CN:-$HOSTNAME}"
    subject="$subject/emailAddress=${CERT_emailAddress:-a@b.cd}"
    subject="${CERT_SUBJECT:-$subject}"

    mkdir -p /etc/squid/ssl_cert
    chmod 750 /etc/squid/ssl_cert
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -extensions v3_ca                               \
        -keyout /etc/squid/ssl_cert/squid.key           \
        -out /etc/squid/ssl_cert/squid.crt              \
        -subj "$subject";

    cat /etc/squid/ssl_cert/squid.key                   \
        /etc/squid/ssl_cert/squid.crt                   \
        > /etc/squid/ssl_cert/squid.pem

    chown -R root:squid /etc/squid/ssl_cert
    chmod 640 /etc/squid/ssl_cert/squid.key
fi

# https://wiki.squid-cache.org/Features/DynamicSslCert
if [ ! -d "/var/lib/squid/ssl_db" ];
then
    mkdir -p /var/lib/squid
    /usr/lib/squid/ssl_crtd -c -s  /var/lib/squid/ssl_db -M 4 MB
    chown -R squid: /var/lib/squid
fi

if [ "$(stat -c %U /var/lib/squid/ssl_db)" != "squid" ];
then
    chown -R squid: /var/lib/squid
fi

# https://github.com/sameersbn/docker-squid/blob/master/entrypoint.sh
if [ ! -d "/var/cache/squid/00" ];
then
  echo "Initializing cache..."
  /usr/sbin/squid -N -f /etc/squid/squid.conf -z
fi

if [ "$(basename $1)" = "squid" ];
then
    rm -f /var/log/squid/*
    trap 'rm -f /var/log/squid/*.log' EXIT SIGINT SIGTERM
    su -s /bin/sh squid -c 'mkfifo /var/log/squid/access.log'
    su -s /bin/sh squid -c 'mkfifo /var/log/squid/cache.log'
    cat /var/log/squid/access.log /var/log/squid/cache.log &

    exec "$@"
else
    exec "$@"
fi
