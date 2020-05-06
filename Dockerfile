FROM geerlingguy/docker-ubi8-ansible
COPY private_unencrypted.pem /private_unencrypted.pem
ADD https://secure.eicar.org/eicar.com /eicar.com
# FROM alpine as builder
# RUN apk update && apk upgrade



