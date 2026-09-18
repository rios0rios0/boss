FROM alpine:3.24.2

RUN apk --no-cache add apache2-utils

WORKDIR /
COPY entrypoint.sh .

ENTRYPOINT ["/entrypoint.sh"]
