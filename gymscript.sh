#!/bin/bash

# Get day of the month
day=$(date +%d)

# Increment the day by one
# so you close appointment for
# the next day
((day++))


# Determine the hours for each day
monday=
tuesday=
wednesday=
thursday=
friday=


# Check what day it is, in order to use the
# correct variable



# Execute curl command, get security code 
security_code=$(curl -s 'https://gym.auth.gr/reservations/' | grep -oP 'ajax_nonce":"\K[^"]+')

# Maybe you need to get the cookie too


# Get available times for the next day



echo "day:$day"
echo "security: $security_code"

