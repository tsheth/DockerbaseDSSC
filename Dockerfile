FROM ubuntu:latest
RUN apt-get update && apt-get install -y
RUN wget https://launchpad.net/glibc/head/2.31/+download/glibc-2.31.tar.gz \
     && tar xvzf glibc-2.31.tar.gz \
     && cd glibc-2.31 \
     && ./configure \
     && make \
     && make install



