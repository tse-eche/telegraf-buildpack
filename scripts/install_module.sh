#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

echo "-----> Install $SIDECAR_NAME binaries"

VERSION="1.20.4"
#URL="https://dl.influxdata.com/telegraf/releases/telegraf-${VERSION}_linux_amd64.tar.gz"

if [ $CF_STACK == "cflinuxfs3" ]; then
    SHA256="f27a8e4a395e5ad7fac7663400b9119b0b0ff77f3baf5e68fa944b40b5094fa4"
else
  echo "       **ERROR** Unsupported stack"
  echo "                 See https://docs.cloudfoundry.org/devguide/deploy-apps/stacks.html for more info"
  exit 1
fi

DepDir="$DEPS_DIR/$DEPS_IDX"
InstallDir="$DepDir/telegraf"

if [ ! -f $InstallDir/telegraf ]; then

  echo "-----> Copy telegraf ${VERSION}"
  mv "$BUILDPACK_DIR/downloads/telegraf-1.20.4_linux_amd64.tar.gz" /tmp/module.tar.gz
#  echo "-----> Download telegraf ${VERSION}"
#  curl -s -L --retry 15 --retry-delay 2 $URL -o /tmp/module.tar.gz

  DOWNLOAD_SHA256=$(shasum -a 256 /tmp/module.tar.gz | cut -d ' ' -f 1)

  if [[ $DOWNLOAD_SHA256 != $SHA256 ]]; then
    echo "       **ERROR** SHA256 mismatch: got $DOWNLOAD_SHA256 expected $SHA256"
    exit 1
  fi

  tar xfz /tmp/module.tar.gz -C $DepDir
  mkdir -p $InstallDir
  mv "$DepDir/telegraf-${VERSION}/usr/bin/telegraf" "$InstallDir/"
  mv "$BUILDPACK_DIR/src/telegraf/telegraf.conf" "$InstallDir/"
  mv "$BUILDPACK_DIR/src/telegraf/THIRD_PARTY_LICENSES" "$InstallDir/"
  rm /tmp/module.tar.gz

  mkdir -p "$DepDir/bin"
  cd $DepDir/bin;
  ln -s "../telegraf/telegraf" "./telegraf" 

fi

if [ ! -f $InstallDir/telegraf ]; then
  echo "       **ERROR** Could not download $SIDECAR_NAME"
  exit 1
fi
