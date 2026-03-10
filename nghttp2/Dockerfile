FROM alpine:3.16.9

RUN apk --no-cache add nghttp2

WORKDIR /
COPY entrypoint.sh .

ENTRYPOINT ["/entrypoint.sh"]
