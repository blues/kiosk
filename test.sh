#!/bin/bash
set -x

INTERFACE="-interface i2c"
PORT="-port /dev/i2c-1"
NOTECARD="$HOME/dev/note-cli/notecard/notecard $INTERFACE $PORT"
PRODUCT="xcom.blues.kiosk"
PROXY="kiosk"
DOWNLOAD="$HOME/kiosk-data/download"

# includes
source download.sh
source request.sh

# Get ready to download a zip file
rm -rf $DOWNLOAD
mkdir -p $DOWNLOAD

# Download the file
download "kiosk-backward.zip" "$DOWNLOAD/download.zip"

# Unzip the download
pushd $DOWNLOAD
unzip download.zip
popd
