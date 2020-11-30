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

isPOSIXDate() {
    date -j -f "%a" "Sat" &> /dev/null
    return $?
}

# calculate the end of the ABB
endDateTime() {
    local ret
    if isPOSIXDate; then
        # we are on BSD
        ret="$(TZ=Asia/Tokyo date -jv +5d -f '%Y-%m-%d' "$startY-$startM-$startD" +'%Y %m %d' )"
    else
        # we are on linux
        ret="$(TZ=Asia/Tokyo date --date "$startY-$startM-$startD+5 day" +'%Y %m %d' )"
    fi
    echo $ret
    return 0
}

getABBDay() {
    local DAY
    local ld
    for DAY in 0 1 2 3 4 5 ; do
        if isPOSIXDate; then
            # we are on BSD
            ld="$(TZ=Asia/Tokyo date -jv +${DAY}d -f '%Y-%m-%d' "$startY-$startM-$startD" +'%Y%m%d' )"
        else
            # we are on linux
            ld="$(TZ=Asia/Tokyo date --date "$startY-$startM-$startD+${DAY} day" +'%Y%m%d' )"
        fi
        if [[ "$ld" -eq "$Y$M$D" ]] ; then
            echo $(( $DAY + 1))
            return 0
        fi
    done
}

# get the current JST date
currentDatetime="$(TZ=Asia/Tokyo date +'%Y %m %d %H %M')"
#echo $currentDatetime

read Y M D h m <<< "$currentDatetime"
read eY eM eD <<< "$(endDateTime)"
#echo "End: $eY $eM $eD"
#echo "ABB Day: $(getABBDay)"

if [[ "$Y$M$D" -lt "$startY$startM$startD" || "$Y$M$D" -gt "$eY$eM$eD" ]]; then
    # current date is not a configured ABB range
    exit 0
fi

# 08 - 09, 12 - 13, 19 - 20, 22 - 23 (in JST)
# get upcoming Round number

# strip 0 for math since leading 0's indicate an octal number.
# if the minute happens to be '09', this fails since '09' is
# not a valid octal number
nm=${m##0}
nm=${nm:-0}
# same as above, but for hours.
nh=${h##0}
nh=${nh:-0}

#echo "H: $h  nh: $nh  M: $m  nm: $nm"

timeTillNext=$((60 - $nm))

if (( $nh == 7 || ($nh == 8 && $nm == 0) )); then
    round="1"
elif (( $nh == 11 || ($nh == 12 && $nm == 0) )); then
    round="2"
elif (( $nh == 18 || ($nh == 19 && $nm == 0) )); then
    round="3"
elif (( $nh == 21 || ($nh == 22 && $nm == 0) )); then
    round="4"
else
    # not close enough to the next round.
    exit
fi

ABB_DAY=$(getABBDay)

# no R1 day 1
if (( $ABB_DAY == 1 && $round == 1 )); then
    exit
fi

if (( $timeTillNext == 60 && ($nh == 8 || $nh == 12 || $nh == 19 || $nh == 22) )); then
    message="ABB Day $ABB_DAY Round $round START! $4"
else
    message="ABB Day $ABB_DAY Round $round in $timeTillNext minutes! $4"
fi

curl -sS -H 'Content-Type: application/json' -X POST -d "{\"content\": \"${message}\"}" "$url"
