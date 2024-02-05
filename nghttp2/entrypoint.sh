#!/usr/bin/env sh
#
# It runs a stress test against to the url passed.

main() {
  h2load -n "$REQUESTS_TOTAL" -c "$REQUESTS_CONCURRENT" -H "$REQUESTS_HEADER" "$TARGET_URL$TARGET_RELATIVE_PATH"
}

main
