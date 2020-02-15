FROM ubuntu as builder
RUN apt-get update
#RUN apt-get upgrade systemd --no-install-recommends -y
#RUN apt-get upgrade libgcrypt20 --no-install-recommends -y
RUN apt-get upgrade e2fsprogs --no-install-recommends -y
RUN apt-get upgrade tar --no-install-recommends -y
RUN apt-get upgrade coreutils --no-install-recommends -y
#RUN apt-get upgrade gnupg2 --no-install-recommends -y
RUN apt-get upgrade util-linux --no-install-recommends -y
RUN apt-get upgrade dpkg --no-install-recommends -y
RUN apt-get upgrade libtasn1-6 --no-install-recommends -y
RUN apt-get upgrade bash --no-install-recommends -y



