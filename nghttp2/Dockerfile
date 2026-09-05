FROM alpine:3.24.1

RUN apk --no-cache add nghttp2

WORKDIR /
COPY entrypoint.sh .

ENTRYPOINT ["/entrypoint.sh"]
