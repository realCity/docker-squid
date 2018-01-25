FROM alpine
MAINTAINER fabio.montefuscolo@gmail.com


RUN apk update                                                \
    && apk add squid                                          \
    && sed -Eie '/^#/d;/^ *$/d' /etc/squid/squid.conf         \
    && sed -i                                                 \
        '1iaccess_log stdio:/var/log/squid/access.log squid'  \
        /etc/squid/squid.conf                                 \
    && rm -rf /var/cache/apk/*

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

EXPOSE 3128/tcp
VOLUME ["/var/cache/squid"]
ENTRYPOINT ["/sbin/entrypoint.sh"]
CMD ["/usr/sbin/squid", "-f", "/etc/squid/squid.conf", "-NYCd", "1"]

