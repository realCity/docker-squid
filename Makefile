all: build

build:
	docker build --tag=montefuscolo/squid-ci .
