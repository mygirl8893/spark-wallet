#!/bin/bash
set -xeo pipefail

[[ -d node_modules ]] || npm install

export BUILD_TARGET=cordova
export DEST=`pwd`/www

mkdir -p $DEST && rm -rf $DEST/*

(cd ../client && npm run dist)

# update config.xml to package.json's version
version=`node -p 'require("../package").version'`
sed -i -r 's/(<widget.*version=")[^"]+/\1'$version'/' config.xml

cordova prepare
cordova build "$@"

# give the .apk file a more descriptive name
(cd platforms/android/app/build/outputs/apk/$([[ "$@" == *"--release" ]] && echo release || echo debug) \
  && mv app-*.apk spark-wallet-$version-android.apk)
