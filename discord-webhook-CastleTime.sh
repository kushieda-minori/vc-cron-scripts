#!/bin/bash

message="One free Castle vitality starting now, ending in 2 hours"
## Webhook URL goes here
url="$1"

currentHour=$(TZ=Asia/Tokyo date +'%H')
currentHour=${currentHour##0}
#echo $currentHour
#exit

# 08 - 10, 12 - 14, 22 - 00 (in JST)
if (( $currentHour ==  8 || $currentHour ==  12 || $currentHour ==  22 )); then
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "$url"
fi

