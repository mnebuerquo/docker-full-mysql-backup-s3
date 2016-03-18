FROM alpine 

MAINTAINER Alvaro Hurtado Mochon <alvarohurtado84@gmail.com>

RUN apk add --update py-pip mysql-client bash apk-cron && \
  pip install awscli && \
  rm -fR /var/cache/apk/*

# this prevent "TERM environment variable not set.""
ENV TERM dumb

RUN mkdir -p /backup
ADD . /backup
RUN chmod +x /backup/bin/*

WORKDIR /backup/bin/

ENTRYPOINT ["/backup/bin/entrypoint"]
