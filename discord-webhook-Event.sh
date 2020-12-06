#!/bin/bash

event_name="${1:-Event}"
# start and end dates should be formatted as follows:
# YYYYMMDDHH
# for example: 2020120712 for year 2020, month 12, day 7, and hour 12 (24 hour format)
event_start=${2}
event_end=${3}

## Webhook URL goes here
url="${4:-http://localhost/}"

currentHour=$(TZ=Asia/Tokyo date +'%Y%m%d%H')


isPOSIXDate() {
    date -j -f "%a" "Sat" &> /dev/null
    return $?
}

# calculate the time 1 hour in the future. this is to give "End of event" notices
oneHourLater() {
    local ret
    if isPOSIXDate; then
        # we are on BSD
        ret="$(TZ=Asia/Tokyo date -jv +1H +'%Y%m%d%H' )"
    else
        # we are on linux
        ret="$(TZ=Asia/Tokyo date --date "+1 hour" +'%Y%m%d%H' )"
    fi
    echo $ret
    return 0
}

oneHrLater=$(oneHourLater)

if [[ "$event_start" -eq "${currentHour}" ]]; then
    message="${event_name} starts now"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
elif [[ "$event_end" -eq "${currentHour}" ]]; then
    message="${event_name} ended"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
elif [[ "$event_end" -eq "${oneHrLater}" ]]; then
    message="${event_name} ending in 1 hour"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
fi

