FROM ubuntu:latest
RUN apt-get update && apt-get install -y
RUN apt-cache policy libc6
RUN apt-get install libc6
RUN apt-cache policy libc6
