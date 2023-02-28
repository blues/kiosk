#!/bin/bash
set -x

# Includes
source download.sh
source request.sh

# Configuration
INTERFACE="-interface i2c"
PORT="-port /dev/i2c-1"
NOTECARD="$HOME/dev/note-cli/notecard/notecard $INTERFACE $PORT"
PRODUCT="com.blues.kiosk"
PROXY="kiosk"

# Set the Notecard operating parameters
req '{"req":"hub.set","product":"'$PRODUCT'","mode":"continuous","sync":true}'

# Set the time and zone from the Notehub under the assumption
# that this RPi isn't connected to the network and so it
# has no idea what time it is.  We need the local time zone
# so that we know when to download new files without
# causing a visual disruption during normal hours.
while [ true ]
do
  req '{"req":"card.time"}'
  TIME=`echo $RSP | jq .time`
  ZONE=`echo $RSP | jq -r .zone | cut -d "," -f 2`
  if [[ "$ZONE" != "Unknown" ]]; then break; fi
  sleep 1
done
sudo date -s '@'$TIME
sudo timedatectl set-timezone $ZONE
