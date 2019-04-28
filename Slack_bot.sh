#!/bin/bash

CHANNEL="#koomely_jenkins"
USERNAME="MyBot"
EMOJI=":ghost:"
MSG="$@"

PAYLOAD="payload={\"channel\": \"$CHANNEL\", \"username\": \"$USERNAME\", \"text\": \"$MSG\", \"icon_emoji\": \"$EMOJI\"}"
HOOK=https://hooks.slack.com/services/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

curl -X POST --data-urlencode "$PAYLOAD" "$HOOK"
