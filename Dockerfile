FROM alpine
MAINTAINER fabio.montefuscolo@gmail.com


RUN apk update                                                \
    && apk add openssl squid                                  \
    && sed -Eie '/^#/d;/^ *$/d' /etc/squid/squid.conf         \
    && rm -rf /var/cache/apk/*

COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp
VOLUME ["/var/cache/squid"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/squid", "-f", "/etc/squid/squid.conf", "-NYCd", "1"]

