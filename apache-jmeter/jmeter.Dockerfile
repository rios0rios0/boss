FROM amazoncorretto:17.0.4-alpine@sha256:7d36057828a4f1eddeb23e10f48f514d68b551887c9d98bf547f1fe8944fe821

ARG JMETER_VERSION="5.5"
RUN cd /opt \
 && wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz \
 && tar xzf apache-jmeter-${JMETER_VERSION}.tgz \
 && rm apache-jmeter-${JMETER_VERSION}.tgz

RUN ln -s /opt/apache-jmeter-${JMETER_VERSION}/bin/jmeter /usr/local/bin
#COPY user.properties /opt/apache-jmeter-${JMETER_VERSION}/bin/user.properties

WORKDIR /
COPY jmeter.entrypoint.sh entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
