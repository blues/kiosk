#!/bin/bash
set -x

INTERFACE="-interface i2c"
PORT="-port /dev/i2c-1"
REQ="$HOME/dev/note-cli/notecard/notecard $INTERFACE $PORT"
PRODUCT="com.blues.ray:kiosk"
HUB="i.staging.blues.tools"

#
# Set the Notecard operating parameters
#
while [ true ]
do
  RSP=`$REQ '{"req":"hub.set","host":"'$HUB'","product":"'$PRODUCT'","mode":"continuous","sync":true}'`
  ERR=`echo $RSP | jq .err`
  if [[ "$ERR" == null ]]; then break; fi
  sleep 1
done

##
## Set the time and zone from the Notehub under the assumption
## that this RPi isn't connected to the network and so it
## has no idea what time it is.  We need the local time zone
## so that we know when to download new files without
## causing a visual disruption during normal hours.
##
while [ true ]
do
  RSP=`$REQ '{"req":"card.time"}'`
  ERR=`echo $RSP | jq .err`
  if [[ "$ERR" == null ]];
  then
      TIME=`echo $RSP | jq .time`
      ZONE=`echo $RSP | jq -r .zone | cut -d "," -f 2`
      if [[ "$ZONE" != "Unknown" ]]; then break; fi
  fi
  sleep 1
done
sudo date -s '@'$TIME
sudo timedatectl set-timezone $ZONE

