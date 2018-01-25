#!/bin/sh
set -e
touch /etc/squid/nobump-sites.txt

if [ ! -f "/etc/squid/ssl_cert/proxy.pem" ];
then
    cat >> /etc/ssl/openssl.cnf << EOF

[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment

[ v3_ca ]
keyUsage = cRLSign, keyCertSign

EOF
    mkdir -p /etc/squid/ssl_cert
    subject="/C=${CERT_C:-BR}"
    subject="$subject/ST=${CERT_ST:-SP}"
    subject="$subject/L=${CERT_L:-São Roque}"
    subject="$subject/O=${CERT_O:-FM}"
    subject="$subject/OU=${CERT_OU:-FM}"
    subject="$subject/CN=${CERT_CN:-$HOSTNAME}"
    subject="$subject/emailAddress=${CERT_emailAddress:-a@b.cd}"
    subject="${CERT_SUBJECT:-$subject}"

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -extensions v3_ca                               \
        -keyout /etc/squid/ssl_cert/proxy.pem           \
        -out /etc/squid/ssl_cert/proxy.pem              \
        -subj "$subject";

    mkdir -p /var/lib/squid
    chown -R squid: /var/lib/squid
    /usr/lib/squid/ssl_crtd -c -s  /var/lib/squid/ssl_db -M 4 MB
fi


if [ ! -d "/var/cache/squid/00" ];
then
  echo "Initializing cache..."
  /usr/sbin/squid -N -f /etc/squid/squid.conf -z
fi


if [ "$(basename $1)" == "squid" ]; then
    trap 'rm -f /var/log/squid/access.log' EXIT SIGINT SIGTERM
    su -s /bin/sh squid -c 'mkfifo /var/log/squid/access.log'
    cat /var/log/squid/access.log &
    echo "$@"
    "$@"
else
    exec "$@"
fi
