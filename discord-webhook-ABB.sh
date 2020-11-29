#!/bin/bash
startY=${1:-2020}
startM=${2:-11}
startD=${3:-27}
mention=${4}
eY=""
eM=""
eD=""
message=""
## Webhook URL goes here
url="$5"

if [ -z $startY ]; then
    echo "no start year month or day specified"
    exit 1
fi

if [ -z $startM ]; then
    echo "no start month or day specified"
    exit 1
fi

if [ -z $startD ]; then
    echo "no start day specified"
    exit 1
fi

if [ -z $url ]; then
    echo "no URL provided"
    exit 1
fi

# calculate the end of the ABB
endDateTime() {
    local ret
    date -j -f "%a" "Sat" &> /dev/null
    if [ $? -eq 0 ]; then
        # we are on BSD
        ret="$(TZ=Asia/Tokyo date -jv +5d -f '%Y-%m-%d' "$1-$2-$3" +'%Y %m %d' )"
    else
        # we are on linux
        ret="$(TZ=Asia/Tokyo date --date "$1-$2-$3+5 day" +'%Y %m %d' )"
    fi
    echo $ret
    return 0
}

# get the current JST date
currentDatetime="$(TZ=Asia/Tokyo date +'%Y %m %d %H %M')"
#echo $currentDatetime

read Y M D h m <<< "$currentDatetime"
read eY eM eD <<< "$(endDateTime $startY $startM $startD)"
echo "End: $eY $eM $eD"

if [[ "$Y$M$D" -lt "$startY$startM$startD" || "$Y$M$D" -gt "$eY$eM$eD" ]]; then
    # current date is not a configured ABB range
    exit 0
fi

# 08 - 09, 12 - 13, 19 - 20, 22 - 23 (in JST)
# get upcoming Round number

timeTillNext=$((60 - $m))

if (( $h ==  7 || ($h == 8 && $m==0) )); then
    round="1"
elif (( $h ==  11 || ($h == 12 && $m==0) )); then
    round="2"
elif (( $h ==  18 || ($h == 19 && $m==0) )); then
    round="3"
elif (( $h ==  21 || ($h == 22 && $m==0) )); then
    round="4"
else
    # not close enough to the next round.
    exit
fi

if (( $timeTillNext == 60 && ($h == 8 || $h == 12 || $h == 19 || $h == 22) )); then
    message="ABB Round $round START! $4"
else
    message="ABB Round $round in $timeTillNext minutes! $4"
fi

curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "$url"
