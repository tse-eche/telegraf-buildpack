#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

LAUNCH_CONTENTS='---
processes:
- type: "telegraf"
  command: "telegraf --config /home/vcap/deps/'$DEPS_IDX'/telegraf/telegraf.conf"
  platforms:
    cloudfoundry:
      
'

echo "-----> Create launch file"
echo "$LAUNCH_CONTENTS" > "$DEPS_DIR"/"$DEPS_IDX"/launch.yml