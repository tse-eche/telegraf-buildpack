#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

VERSION="1.18.0"
URL="https://dl.influxdata.com/telegraf/releases/telegraf-${VERSION}_linux_amd64.tar.gz"

if [ $CF_STACK == "cflinuxfs3" ]; then
    SHA256="a3a8b950c7dc63c03e46140f2abd016cc31cbfff02f5152d5c85d80fef4295e4"
else
  echo "       **ERROR** Unsupported stack"
  echo "                 See https://docs.cloudfoundry.org/devguide/deploy-apps/stacks.html for more info"
  exit 1
fi

DepDir="$DEPS_DIR/$DEPS_IDX"
InstallDir="$DepDir/telegraf"

if [ ! -f $InstallDir/telegraf ]; then
  
  # echo "-----> Download telegraf ${VERSION}"
  # curl -s -L --retry 15 --retry-delay 2 $URL -o /tmp/module.tar.gz

  # DOWNLOAD_SHA256=$(shasum -a 256 /tmp/module.tar.gz | cut -d ' ' -f 1)

  # if [[ $DOWNLOAD_SHA256 != $SHA256 ]]; then
  #   echo "       **ERROR** SHA256 mismatch: got $DOWNLOAD_SHA256 expected $SHA256"
  #   exit 1
  # fi

  # tar xfz /tmp/module.tar.gz -C $DepDir
  # mv "$DepDir/node_exporter-${VERSION}.linux-amd64" $InstallDir
  # rm /tmp/module.tar.gz

  mv "$BUILDPACK_DIR/src/telegraf" $InstallDir
  
  mkdir -p "$DepDir/bin"
  cd $DepDir/bin;
  ln -s "../telegraf/telegraf" "./telegraf" 

fi

if [ ! -f $InstallDir/telegraf ]; then
  echo "       **ERROR** Could not download telegraf"
  exit 1
fi
