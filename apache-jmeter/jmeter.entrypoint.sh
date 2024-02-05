#!/usr/bin/env sh
#
# It runs a stress test against to the url passed.

main() {
  sleep 5s
  export IFS=","
  for apiName in $TARGET_API_NAMES; do
    mkdir -p "$OUTPUT_FOLDER/$apiName"
    jmeter -n -t "$INPUT_FOLDER/$apiName.jmx" -l "$OUTPUT_FOLDER/$apiName-test.csv" -e -o "$OUTPUT_FOLDER/$apiName"
  done
}

main
