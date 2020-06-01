FROM python:3.6-alpine

LABEL description="ElastAlert suitable for Kubernetes and Helm"
LABEL maintainer="Skillz (devops@skillz.com)"

RUN apk --update upgrade && \
  apk add gcc libffi-dev musl-dev python-dev openssl-dev tzdata libmagic && \
  rm -rf /var/cache/apk/*

ADD dist/elastalert-${ELASTALERT_VERSION}-py3-none-any.whl /tmp/elastalert-${ELASTALERT_VERSION}-py3-none-any.whl
RUN pip install /tmp/elastalert-${ELASTALERT_VERSION}-py3-none-any.whl && \
  apk del gcc libffi-dev musl-dev python-dev openssl-dev

RUN mkdir -p /opt/elastalert && \
  echo "#!/bin/sh" >> /opt/elastalert/run.sh && \
  echo "set -e" >> /opt/elastalert/run.sh && \
  echo "elastalert-create-index --config /opt/config/elastalert_config.yaml" >> /opt/elastalert/run.sh && \
  echo "exec elastalert --config /opt/config/elastalert_config.yaml \"\$@\"" >> /opt/elastalert/run.sh && \
  chmod +x /opt/elastalert/run.sh

ENV TZ "UTC"

WORKDIR /opt/elastalert
ENTRYPOINT ["/opt/elastalert/run.sh"]
