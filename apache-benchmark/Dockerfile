FROM alpine:3.16.9

RUN apk --no-cache add apache2-utils

WORKDIR /
COPY entrypoint.sh .

ENTRYPOINT ["/entrypoint.sh"]
