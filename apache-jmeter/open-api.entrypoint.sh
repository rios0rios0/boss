#!/usr/bin/env sh
#
# It downloads and converts the OA spec to JMeter JMX format.

main() {
  rm -rf "${INPUT_FOLDER:?}/*"
  wget "$TARGET_DOCS_URL" --output-document "$INPUT_FOLDER/open-api.yaml"
  rm -rf "${OUTPUT_FOLDER:?}/*" "$OUTPUT_FOLDER/.openapi-generator" "$OUTPUT_FOLDER/.openapi-generator-ignore"
  /usr/local/bin/docker-entrypoint.sh generate -i "$INPUT_FOLDER/open-api.yaml" -g jmeter -o "$OUTPUT_FOLDER"
}

main
