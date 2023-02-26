#!/bin/bash
set -x

INTERFACE="-interface i2c"
PORT="-port /dev/i2c-1"
NOTECARD="$HOME/dev/note-cli/notecard/notecard $INTERFACE $PORT"
PRODUCT="com.blues.ray:kiosk"
HUB="i.staging.blues.tools"

RSP=`$NOTECARD '{"req":"hub.set","hub":"'$HUB'","product":"'$PRODUCT'","mode":"continuous","sync":true}'`
ERR=`echo $RSP | jq .err`
echo "error is "$ERR
