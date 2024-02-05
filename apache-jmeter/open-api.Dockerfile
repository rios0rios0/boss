FROM openapitools/openapi-generator-cli:v6.0.1@sha256:c49d9c99124fe2ad94ccef54cc6d3362592e7ca29006a8cf01337ab10d1c01f4

WORKDIR /
COPY open-api.entrypoint.sh entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
