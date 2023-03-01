#!/bin/bash
set +x

# Includes
source download.sh
source request.sh

# If the Notecard utility exists on the path, assume it is set up properly
if [[ `which notecard` != "" ]]
then
	INTERFACE=""
	PORT=""
	NOTECARD="notecard"
	SETTIME=false
else
	INTERFACE="-interface i2c"
	PORT="-port /dev/i2c-1"
	NOTECARD="$HOME/dev/note-cli/notecard/notecard $INTERFACE $PORT"
	SETTIME=true
fi

# Configuration
DOWNLOAD="$HOME/kiosk-data/download"
ACTIVE="$HOME/kiosk-data/active"
ACTIVEHTML="$ACTIVE/resources/index.htm"
ACTIVEDATA="$ACTIVE/resources/data.js"
PRODUCT="com.blues.kiosk"
PROXY="kiosk"

# TEST
if [[ false == true ]]; then
unclutter -idle 0
xset -dpms     # disable DPMS (Energy Star) features.
xset s off     # disable screen saver
xset s noblank # don't blank the video device
timeout 20 chromium-browser --display=:0 --kiosk --incognito --window-position=0,0 file://$ACTIVEHTML
fi

# Set the Notecard operating parameters
echo "Configuring Notecard"
req '{"req":"hub.set","product":"'$PRODUCT'","mode":"continuous","sync":true}'

# Set the time and zone from the Notehub under the assumption
# that this RPi isn't connected to the network and so it
# has no idea what time it is.  We need the local time zone
# so that we know when to download new files without
# causing a visual disruption during normal hours.
if [[ "$SETTIME" == true ]]; then
	echo "Waiting for Notecard to acquire time-of-day"
	while [ true ]
	do
		req '{"req":"card.time"}'
		TIME=`echo $RSP | jq .time`
		ZONE=`echo $RSP | jq -r .zone | cut -d "," -f 2`
		if [[ "$ZONE" != "Unknown" ]]; then break; fi
		sleep 1
	done
	echo "Setting local time-of-day"
	sudo date -s '@'$TIME
	sudo timedatectl set-timezone $ZONE
fi

# Main loop
while [ true ]
do

	# Get the environment vars
	req '{"req":"env.get"}'
	DATA=`echo $RSP | jq -r .body.kiosk_data`
	CONTENT=`echo "$RSP" | jq -r .body.kiosk_content`
	CONTENT_VERSION=`echo $RSP | jq -r .body.kiosk_content_version`
	DOWNLOAD_TIME=`echo $RSP | jq -r .body.kiosk_download_time`

	# Reload what version we've downloaded
	KIOSK_CONTENT=`cat "$ACTIVE/vars/CONTENT" 2>/dev/null`
	KIOSK_CONTENT_VERSION=`cat "$ACTIVE/vars/CONTENT_VERSION" 2>/dev/null`

	# If this is not the current local time, it's not ok to download.
	DOWNLOAD_NOW=false
	if [[ `date +"%H"` == "$DOWNLOAD_TIME" ]]; then
	   DOWNLOAD_NOW=true
	fi
	# However, if it's non-numeric, it's always OK to download
	if ! [[ $DOWNLOAD_TIME =~ ^[0-9]+$ ]]; then
	   DOWNLOAD_NOW=true
	fi

	# If the content filename and version haven't changed, download
	if [[ "$CONTENT" == "" ]]; then
		DOWNLOAD_NOW=false
	else
		if [[ "$CONTENT" == "$KIOSK_CONTENT" ]]; then
			if [[ "$CONTENT_VERSION" == "" || "$CONTENT_VERSION" == "$KIOSK_CONTENT_VERSION" ]]; then
				DOWNLOAD_NOW=false
			fi
		fi
	fi

	# If it's time to download, do it
	if [[ "$DOWNLOAD_NOW" == true ]]; then
		echo "Downloading $CONTENT"

		# Do the download
		rm -rf $DOWNLOAD
		mkdir -p $DOWNLOAD
		download "$CONTENT" "$DOWNLOAD/download.zip"
		pushd $DOWNLOAD
		unzip download.zip
		popd

		# Remember what we downloaded
		mkdir -p $DOWNLOAD/vars
		echo "$CONTENT" >$DOWNLOAD/vars/CONTENT
		echo "$CONTENT_VERSION" >$DOWNLOAD/vars/CONTENT_VERSION

		# Make it active
		mkdir -p $ACTIVE
		cp -R $DOWNLOAD/* $ACTIVE

		# Force the kiosk data to be rewritten
		KIOSK_DATA=""

	fi

	# Rewrite the data file and save for next iteration
	if [[ "$DATA" != "" && "$DATA" != "$KIOSK_DATA" ]]; then
		echo "Writing new data: $DATA"
		echo "var data = $DATA" >$ACTIVEDATA
	fi
	KIOSK_DATA="$DATA"

	# Pause
	sleep 5

done
