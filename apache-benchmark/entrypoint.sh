#!/usr/bin/env sh
#
# It runs a stress test against to the url passed.

main() {
  # cat /mnt/urls/urls | parallel --colsep ',' "ab -e {2} -c 2 -n 200 {1} && cat {2} | tail -n 100 | sed 's/^/{2},/' >> /tmp/ab.csv"
  ab -s "$SOCKET_TIMEOUT_SECONDS" -n "$REQUESTS_TOTAL" -c "$REQUESTS_CONCURRENT" -H "$REQUESTS_HEADER" "$TARGET_URL$TARGET_RELATIVE_PATH"
}

main
