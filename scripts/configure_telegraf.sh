#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

echo "-----> Configuring telegraf"

TELEGRAF_CONF_FILE=$DEPS_DIR/$DEPS_IDX/telegraf/telegraf.conf

getGraphiteUrl()
{
    echo $(echo $VCAP_SERVICES | jq -r '."a9s-prometheus"[0].credentials."graphite_exporters"[0]')
}

getGraphitePort()
{
    echo $(echo $VCAP_SERVICES | jq '."a9s-prometheus"[0].credentials."graphite_exporter_port"')
}

# GRAPHITE_URL=$(getGraphiteUrl)
# GRAPHITE_PORT=$(getGraphitePort)

# if [ ${GRAPHITE_URL} == "null" ]; then
#   echo "       **ERROR** No Graphite configuration found in Services!"
#   echo "                 Please add the a9s_Prometheus Service to use this buildpack!"
#   exit 1
# fi

# sed -i 's/localhost:2003/'$GRAPHITE_URL':'$GRAPHITE_PORT'/' $TELEGRAF_CONF_FILE

# echo "-----> GraphiteURL: '$GRAPHITE_URL:$GRAPHITE_PORT'"

if [ -z ${PROM_HOST+x} ]; 
then 
  export PROM_HOST="localhost"
fi

if [ -z ${PROM_PORT+x}  ]; 
then 
  export PROM_PORT=9100
fi

if [ -z ${PROM_PATH+x}  ]; 
then 
  export PROM_PATH="metrics"
fi

sed -i 's|localhost:9100/metrics|'$PROM_HOST':'$PROM_PORT'/'$PROM_PATH'|' $TELEGRAF_CONF_FILE

echo "-----> Prometheus-URL: '$PROM_HOST:$PROM_PORT/$PROM_PATH'"