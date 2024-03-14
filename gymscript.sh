#!/bin/bash

# Determine the hours for each day
# Range: 9 to 21:30
monday='"09:00"'
tuesday="09:00"
wednesday="10:00"
thursday='"20:00"'
friday="15:00"

# Get date of the month
DATE=$(date +%d)
# Get the name of the day
day=$(date +%A)

# If it's friday then date+=3
# to close appointment for monday
# else date++ for the next day

# No need to check if it is
# the weekend; cron scheduler
# takes care of that

if [ $day = "Friday" ]; then
	DATE=$((DATE + 3))
else
	DATE=$((DATE + 1))
fi

# Check what day it is, in order to use the
# correct variable

case $day in 
	"Monday")
		TIME=$monday
		;;
	"Tuesday")
		TIME=$tuesday
		;;
	"Wednesday")
        	TIME=$wednesday
        	;;
    	"Thursday")
        	TIME=$thursday
        	;;
    	"Friday")
        	TIME=$friday
        	;;
    	*)
		;;
esac

#====================================================================#

# Execute curl command, get security code 
SECURITY_CODE=$(curl -s 'https://gym.auth.gr/reservations/' | grep -oP 'ajax_nonce":"\K[^"]+')
# Execute curl command, get cookie
COOKIE=$(curl -sI 'https://gym.auth.gr/reservations' | grep -oP 'Set-Cookie: PHPSESSID=\K[^;]+')

# Use  security code and cookie to make GET and POST requests
# Using: $COOKIE, $SECURITY_CODE, $DATE, $(date +%H)
# There might be a problem with the time section
# in the --data-raw option --> seconds are either 00 or 30
# and you made it 00 only


TIMES_SET=$(curl -s 'https://gym.auth.gr/wp-admin/admin-ajax.php?lang=el' \
  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
  -H 'Accept-Language: en-US,en;q=0.9' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  -H "Cookie: PHPSESSID=$COOKIE; pll_language=el" \
  -H 'Origin: https://gym.auth.gr' \
  -H 'Referer: https://gym.auth.gr/reservations/' \
  -H 'Sec-Fetch-Dest: empty' \
  -H 'Sec-Fetch-Mode: cors' \
  -H 'Sec-Fetch-Site: same-origin' \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H 'sec-ch-ua: "Chromium";v="122", "Not(A:Brand";v="24", "Google Chrome";v="122"' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'sec-ch-ua-platform: "Linux"' \
  --data-raw "sln%5Bdate%5D=2024-03-$DATE&sln%5Btime%5D=$(date +%H)%3A00&sln%5Bservices%5D%5B11192%5D=1&sln%5Bcustomer_timezone%5D=Europe%2FAthens&sln_step_page=services&submit_services=next&action=salon&method=salonStep&security=$SECURITY_CODE" | jq -r '.content' | grep -oP '(?<={)[^}]*(?=})' | sed 's/&quot;/"/g' | grep -oP '"times":{\K[^}]+' | awk -F '[:,]' '{ for(i=1; i<=NF; i+=2) print $i ":" $(i+1) }' | sort -u)


echo $TIME
#echo $DATE
#echo $day
#echo $COOKIE
#echo $security_code
printf "%s\n" "$TIMES_SET"
