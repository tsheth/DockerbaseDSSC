FROM ubuntu:latest
RUN apt-get update && apt-get install -y
RUN wget https://launchpad.net/glibc/head/2.31/+download/glibc-2.31.tar.gz


