#!/bin/bash

message="$1"
## Webhook URL goes here
url="$2"

curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "$url"
