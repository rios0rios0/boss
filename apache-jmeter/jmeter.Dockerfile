FROM amazoncorretto:26.0.2-alpine

ARG JMETER_VERSION="5.5"
# SHA-512 published next to the tarball at
# https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz.sha512
# and must be bumped together with JMETER_VERSION.
ARG JMETER_SHA512="d5d1ce795e9baf18efd3a13ecda150b4da80c3173a2c7ef0da2a5546ac6862b1edd2a2f4e52d971c7da05d879362c28dca6bf218c5f7570b5cc98f7ba73c92af"
# The base image only ships BusyBox wget, which cannot restrict redirects, so
# curl is installed for the download and removed again afterwards. Redirects
# are not followed (no -L) and --proto pins the request to HTTPS, so the
# download can never be bounced to a plain-HTTP location; the checksum then
# guards the bytes that actually arrived.
RUN apk add --no-cache --virtual .fetch-deps curl \
 && curl --proto '=https' --fail --silent --show-error \
      --output "/opt/apache-jmeter-${JMETER_VERSION}.tgz" \
      "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz" \
 && echo "${JMETER_SHA512}  /opt/apache-jmeter-${JMETER_VERSION}.tgz" | sha512sum -c - \
 && tar -xzf "/opt/apache-jmeter-${JMETER_VERSION}.tgz" -C /opt \
 && rm "/opt/apache-jmeter-${JMETER_VERSION}.tgz" \
 && ln -s "/opt/apache-jmeter-${JMETER_VERSION}/bin/jmeter" /usr/local/bin \
 && apk del .fetch-deps
#COPY user.properties /opt/apache-jmeter-${JMETER_VERSION}/bin/user.properties

WORKDIR /
COPY jmeter.entrypoint.sh entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
