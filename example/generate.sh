
[ -e kiosk.json ] && rm kiosk.json
rm ../resources/* 2>/dev/null

cp forward.json ../kiosk.json
cp forward.htm ../resources/index.htm
cp forward.js ../resources/data.js
cp images/* ../resources
pushd ..
./package.sh
popd
cp ../kiosk.zip kiosk-forward.zip

rm ../kiosk.json
rm ../resources/*
cp backward.json ../kiosk.json
cp backward.htm ../resources/index.htm
cp backward.js ../resources/data.js
cp images/* ../resources
pushd ..
./package.sh
popd
cp ../kiosk.zip kiosk-backward.zip

rm ../kiosk.json
rm ../kiosk.zip
rm ../resources/*
