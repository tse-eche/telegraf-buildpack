#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

CONFIG_CONTENTS='
name: telegraf
version: '$(cat "$BUILDPACK_DIR/VERSION")'
config: {}
'

echo "-----> Create config file"
echo "$CONFIG_CONTENTS" > "$DEPS_DIR"/"$DEPS_IDX"/config.yml