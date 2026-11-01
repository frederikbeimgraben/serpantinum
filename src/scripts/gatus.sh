#!/usr/bin/env bash
# Prints the state of Gatus status pages as one JSON array. The gatus module
# of the bar reads it, see quickshell/singletons/system/Gatus.qml.
# Arguments: the base URLs of the Gatus instances.
# Each instance gives its URL, its host, whether the API answered, the number
# of endpoints, and the endpoints whose latest result failed. pageSize=1 makes
# Gatus send only the latest result of each endpoint.
for url in "$@"; do
    base="${url%/}"
    host="${base#*://}"
    host="${host%%/*}"
    body=$(curl -fsS -m 10 "$base/api/v1/endpoints/statuses?page=1&pageSize=1" 2>/dev/null)
    if [ -z "$body" ] || ! jq -e 'type == "array"' <<<"$body" >/dev/null 2>&1; then
        jq -nc --arg url "$base" --arg host "$host" \
            '{url: $url, host: $host, reachable: false, total: 0, failing: []}'
        continue
    fi
    jq -c --arg url "$base" --arg host "$host" '{
        url: $url,
        host: $host,
        reachable: true,
        total: length,
        failing: [.[] | select((.results // []) | length > 0 and (last.success | not))
                  | {name, group: (.group // ""), key}]
    }' <<<"$body"
done | jq -sc '.'
