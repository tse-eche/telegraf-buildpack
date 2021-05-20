#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

CONFIG_CONTENTS='
name: '$SIDECAR_NAME'
version: '$(cat "$BUILDPACK_DIR/VERSION")'
config: {}
'

echo "-----> Create $SIDECAR_NAME config file"
echo "$CONFIG_CONTENTS" > "$DEPS_DIR"/"$DEPS_IDX"/config.yml