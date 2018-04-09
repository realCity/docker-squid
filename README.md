# SQUID Cache

This container runs an instance of __Squid 3.5.23__ with __SSL Bump__ feature pre-configured. My knowledge about Squid is limited, so __squid.conf__ was created by copying and pasting some pieces from Web. But I guess it can cache agressively several kind of files.


## Motivation

We run serveral build jobs using a CI tool and also on development environment, we have to run dependencies managers several times whe creating Dockerfile to test our images. So we took `sameersbn/squid` image and changed to fit our needs.


## How to use

### 1. Run container
```
docker run --name squid                                          \
    --volume /etc/squid/ssl_cert:/etc/squid/ssl_cert             \
    -d montefuscolo/squid
```

### 2. Get your proxy address
```
http_proxy=$(
    docker inspect squid                                         \
        --format 'http://{{ .NetworkSettings.IPAddress }}:3128'
)
https_proxy=$(
    docker inspect squid                                         \
        --format 'http://{{ .NetworkSettings.IPAddress }}:3128'
)
```

### 3. Install squid certificate on your system

It may vary from system to system. Unfortunately, I'm pretty sad to fail installing certificates on Archlinux. If someone knows how to do this on Archlinux or any other distro, please, create a pull request to this file.

This works on alpine.
```
cp /etc/squid/ssl_cert/squid.crt /usr/local/share/ca-certificates/squid.crt
update-ca-certificates
```

This works on Debian 8 and probably Ubuntu too
```
mkdir /usr/local/share/ca-certificates/squid.localhost
cp /etc/squid/ssl_cert/squid.crt\
    /usr/local/share/ca-certificates/squid.localhost
update-ca-certificates
```

### 4. Build an Image for your project

```
docker build                                                     \
    --build-arg="http_proxy=$http_proxy"                         \
    --build-arg="https_proxy=https_proxy"                        \
    -t hacklab/php:7-apache .
```


## Good to know

The certifcate generate by container is a CA certificate. Squid will intercept https calls and do a lot of magic to create a fake signed certifacate to each site accessed. Basically, squid will be a __man in the middle__ of your requests. If you use this container to proxy important things and also let someone steal `squid.crt` and `squid.key` or `squid.pem`, this someone can create be a man in the middle for your requests too.


## Help needed

Please, create pull requests or comment any suggestion you have.


## References

* http://marek.helion.pl/install/squid.html
* https://aacable.wordpress.com/2013/08/13/videocache-and-squid-configuration-short-notes/
* https://gist.github.com/hvrauhal/f98d7811f19ad1792210
* https://wiki.squid-cache.org/Features/DynamicSslCert

