FROM alpine:3.16.1@sha256:9b2a28eb47540823042a2ba401386845089bb7b62a9637d55816132c4c3c36eb

RUN apk --no-cache add nghttp2

WORKDIR /
COPY entrypoint.sh .

ENTRYPOINT ["/entrypoint.sh"]
