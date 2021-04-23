FROM python:3.7-alpine

LABEL description="ElastAlert suitable for Kubernetes and Helm"
LABEL maintainer="Skillz (devops@skillz.com)"

ARG ELASTALERT_VERSION=0.2.4

RUN apk --update upgrade && \
    apk add gcc libffi-dev musl-dev python3-dev openssl-dev tzdata libmagic cargo jq curl && \
    rm -rf /var/cache/apk/*

RUN pip install elastalert==${ELASTALERT_VERSION} && \
    apk del gcc libffi-dev musl-dev python3-dev openssl-dev cargo

RUN mkdir -p /opt/elastalert && \
  echo "#!/bin/sh" >> /opt/elastalert/run.sh && \
  echo "set -e" >> /opt/elastalert/run.sh && \
  echo "elastalert-create-index --config /opt/config/elastalert_config.yaml" >> /opt/elastalert/run.sh && \
  echo "exec elastalert --config /opt/config/elastalert_config.yaml \"\$@\"" >> /opt/elastalert/run.sh && \
  chmod +x /opt/elastalert/run.sh

ENV TZ "UTC"

WORKDIR /opt/elastalert
ENTRYPOINT ["/opt/elastalert/run.sh"]