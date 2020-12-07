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
xHourLater() {
    local ret
    if isPOSIXDate; then
        # we are on BSD
        ret="$(TZ=Asia/Tokyo date -jv +${1}H +'%Y%m%d%H' )"
    else
        # we are on linux
        ret="$(TZ=Asia/Tokyo date --date "+${1} hour" +'%Y%m%d%H' )"
    fi
    echo $ret
    return 0
}

oneHrLater=$(xHourLater 1)
twoHrLater=$(xHourLater 2)
oneDayLater=$(xHourLater 24)
twoDayLater=$(xHourLater 48)

if [[ "$event_start" -eq "${currentHour}" ]]; then
    message="${event_name} starts now"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
elif [[ "$event_start" -eq "${oneHrLater}" ]]; then
    message="${event_name} starts in 1 hour"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
elif [[ "$event_end" -eq "${currentHour}" ]]; then
    message="${event_name} ended"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
elif [[ "$event_end" -eq "${oneHrLater}" ]]; then
    message="${event_name} ending in 1 hour"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
elif [[ "$event_end" -eq "${twoHrLater}" ]]; then
    message="${event_name} ending in 2 hours"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
elif [[ "$event_end" -eq "${oneDayLater}" ]]; then
    message="${event_name} ending in 24 hours"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
elif [[ "$event_end" -eq "${twoDayLater}" ]]; then
    message="${event_name} ending in 48 hours"
    curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "${url}"
fi

