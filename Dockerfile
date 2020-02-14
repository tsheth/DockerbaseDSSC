FROM ubuntu:latest
RUN apt-get update && apt-get install -y
RUN curl https://launchpad.net/glibc/head/2.31/+download/glibc-2.31.tar.gz --output glibc-2.31.tar.gz


