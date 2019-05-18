FROM alpine as builder

COPY fake-rhel.tgz /

RUN mkdir /fake-rhel && tar x -C /fake-rhel -z -f /fake-rhel.tgz

# FROM gcr.io/argus-deploy/rhel7-bruce:latest as rhel-builder

FROM scratch

# This should trick clair into thinking the system is alpine
COPY --from=builder /etc/alpine-release /etc/alpine-release

# This will trigger at least 3 medium vulnerabilities in apache2
COPY lib-apk-db-installed /lib/apk/db/installed

# This will trigger a malware finding
ADD https://secure.eicar.org/eicar.com /eicar.com

# This will trigger a content finding for a private key in PEM format
COPY private_unencrypted.pem /private_unencrypted.pem

# This will trigger an oscap finding for wordpress
COPY wpversion /fake/wp-includes/version.php

# This will trigger the checklist scanner
COPY --from=builder /fake-rhel /

#COPY --from=rhel-builder /etc/redhat-release /etc/system-release-cpe /etc/
#COPY --from=rhel-builder /usr/lib/rpm /usr/lib/rpm
#COPY --from=rhel-builder /var/lib/rpm /var/lib/rpm
