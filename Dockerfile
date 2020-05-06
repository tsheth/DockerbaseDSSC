FROM geerlingguy/docker-ubi8-ansible
COPY private_unencrypted.pem /private_unencrypted.pem
# FROM alpine as builder
# RUN apk update && apk upgrade



