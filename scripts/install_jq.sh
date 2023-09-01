#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

echo "-----> Install JQ binaries"

VERSION="1.6"
#URL="https://github.com/stedolan/jq/releases/download/jq-${VERSION}/jq-linux64"
#
#if [ $CF_STACK == "cflinuxfs3" ]; then
if [ "$CF_STACK" == "cflinuxfs3" ] || [ "$CF_STACK" == "cflinuxfs4" ] || [ -z "${CF_STACK+x}" ]; then
    SHA256="af986793a515d500ab2d35f8d2aecd656e764504b789b66d7e1a0b727a124c44"
else
  echo "       **ERROR** Unsupported stack: $CF_STACK"
  echo "                 See https://docs.cloudfoundry.org/devguide/deploy-apps/stacks.html for more info"
  exit 1
fi

DepDir="$DEPS_DIR/$DEPS_IDX"
InstallDir="$DepDir/jq"

mkdir -p $InstallDir

if [ ! -f $InstallDir/jq-linux64 ]; then
  
  echo "-----> Copy jq ${VERSION}"
  mv "$BUILDPACK_DIR/downloads/jq-linux64" "$InstallDir/jq-linux64"
#  echo "-----> Download jq ${VERSION}"
#  curl -L --retry 15 --retry-delay 2 $URL -o $InstallDir/jq-linux64

  DOWNLOAD_SHA256=$(shasum -a 256 $InstallDir/jq-linux64 | cut -d ' ' -f 1)

  if [[ $DOWNLOAD_SHA256 != $SHA256 ]]; then
    echo "       **ERROR** SHA256 mismatch: got $DOWNLOAD_SHA256 expected $SHA256"
    exit 1
  fi

  mkdir -p "$DepDir/bin"
  cd $DepDir/bin;
  ln -s "../jq/jq-linux64" "./jq"

fi

if [ ! -f $InstallDir/jq-linux64 ]; then
  echo "       **ERROR** Could not download jq"
  exit 1
fi
