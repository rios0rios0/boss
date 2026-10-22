FROM alpine:3.24.3

RUN apk --no-cache add nghttp2

WORKDIR /
COPY entrypoint.sh .

ENTRYPOINT ["/entrypoint.sh"]
