#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

echo "-----> Install $SIDECAR_NAME binaries"

VERSION="1.18.3"
URL="https://dl.influxdata.com/telegraf/releases/telegraf-${VERSION}_linux_amd64.tar.gz"

if [ $CF_STACK == "cflinuxfs3" ]; then
    SHA256="8fa528ad53d4e23bf52e0abb93125134b4f46755b2f28331c27119a078542f9c"
else
  echo "       **ERROR** Unsupported stack"
  echo "                 See https://docs.cloudfoundry.org/devguide/deploy-apps/stacks.html for more info"
  exit 1
fi

DepDir="$DEPS_DIR/$DEPS_IDX"
InstallDir="$DepDir/telegraf"

if [ ! -f $InstallDir/telegraf ]; then
  
  echo "-----> Download telegraf ${VERSION}"
  curl -s -L --retry 15 --retry-delay 2 $URL -o /tmp/module.tar.gz

  DOWNLOAD_SHA256=$(shasum -a 256 /tmp/module.tar.gz | cut -d ' ' -f 1)

  if [[ $DOWNLOAD_SHA256 != $SHA256 ]]; then
    echo "       **ERROR** SHA256 mismatch: got $DOWNLOAD_SHA256 expected $SHA256"
    exit 1
  fi

  tar xfz /tmp/module.tar.gz -C $DepDir
  mv "$DepDir/telegraf-${VERSION}_linux_amd64" $InstallDir
  rm /tmp/module.tar.gz

  # mv "$BUILDPACK_DIR/src/telegraf" $InstallDir
  
  mkdir -p "$DepDir/bin"
  cd $DepDir/bin;
  ln -s "../telegraf/telegraf" "./telegraf" 

fi

if [ ! -f $InstallDir/telegraf ]; then
  echo "       **ERROR** Could not download $SIDECAR_NAME"
  exit 1
fi
