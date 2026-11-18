#!/usr/bin/env bash
set -u

target="http://10.77.40.10"
timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

if code=$(curl --silent --show-error \
    --connect-timeout 5 --max-time 10 \
    --output /dev/null --write-out '%{http_code}' \
    "$target"); then
    if [ "$code" = "200" ]; then
        printf '%s OK WEB01 HTTP %s\n' "$timestamp" "$code"
        exit 0
    fi
    printf '%s FAIL WEB01 unexpected HTTP %s\n' "$timestamp" "$code"
else
    printf '%s FAIL WEB01 connection failed\n' "$timestamp"
fi

exit 1
