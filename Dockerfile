FROM kong/kong-gateway:2.8.1.2-rhel7

USER root
COPY readiness.sh /usr/local/bin/readiness.sh
RUN chmod +x /usr/local/bin/readiness.sh
USER kong
