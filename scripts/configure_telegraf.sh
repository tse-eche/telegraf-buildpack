#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

TELEGRAF_CONF_FILE=$DEPS_DIR/$DEPS_IDX/telegraf/telegraf.conf

getGraphiteUrl()
{
    echo $(echo $VCAP_SERVICES | jq -r '."a9s-prometheus"[0].credentials."graphite_exporters"[0]')
}

getGraphitePort()
{
    echo $(echo $VCAP_SERVICES | jq '."a9s-prometheus"[0].credentials."graphite_exporter_port"')
}

GRAPHITE_URL=$(getGraphiteUrl)
GRAPHITE_PORT=$(getGraphitePort)

if [ ($GRAPHITE_URL == null -o $GRAPHITE_URL == "") -o ($GRAPHITE_PORT == null -o $GRAPHITE_PORT == "")]; then
  echo "       **ERROR** No Graphite configuration found in Services!"
  echo "                 Please add the a9s_Prometheus Service to use this buildpack!"
  exit 1
fi

sed -i 's/localhost:2003/'$GRAPHITE_URL':'$GRAPHITE_PORT'/' $TELEGRAF_CONF_FILE

echo "GraphiteURL $GRAPHITE_URL:$GRAPHITE_PORT!"

# sed -i 's/9273/9100/' $TELEGRAF_CONF_FILE

# cat $TELEGRAF_CONF_FILE