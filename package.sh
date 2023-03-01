
# Delete old zip
[ -e kiosk.zip ] && rm kiosk.zip

# Build the metadata so that it appears robustly in the Notehub firmware UI.  Note that the embedded
# firmware info string must be null-terminated, and must be embedded in the ZIP with no compression
# so that it can be extracted from the cleartext within the ZIP file when it's uploaded.
mkdir -p metadata;
echo -n "firmware::info:"$(jq --compact-output ". + {built: now | todateiso8601} + {builder: \""$(whoami)"\"}" kiosk.json) | tr -d '\n' | tr -d '\r'  >metadata/info.bin
printf '\0' >>metadata/info.bin

# Build the ZIP
echo "Building kiosk.zip"
cat kiosk.json
echo ""
zip kiosk.zip -0 metadata/*
zip kiosk.zip resources/*

# Clean up
rm -rf metadata
