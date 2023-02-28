#!/bin/bash
set -x

REQ="notecard"
PRODUCT="com.blues.ray:kiosk"
PROXY="kiosk"

# includes
source download.sh
source request.sh

# Get ready to download a zip file
rm -rf ./download 2>/dev/null
mkdir ./download

# Download the file
download "kiosk-backward.zip" "download/download.zip"

# Unzip the download
pushd download
unzip download.zip
popd
