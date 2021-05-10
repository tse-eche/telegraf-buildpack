#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

echo "-----> Configuring telegraf"

TELEGRAF_CONF_FILE=$DEPS_DIR/$DEPS_IDX/telegraf/telegraf.conf

getApplicationName()
{
    echo $(echo $VCAP_APPLICATION | jq -r '.application_name')
}

getGraphiteUrl()
{
    echo $(echo $VCAP_SERVICES | jq -r '."a9s-prometheus"[0].credentials."graphite_exporters"[0]')
}

getGraphitePort()
{
    echo $(echo $VCAP_SERVICES | jq '."a9s-prometheus"[0].credentials."graphite_exporter_port"')
}

if [ -z ${APPLICATION_NAME+x} ]; 
then 
  export APPLICATION_NAME=$(getApplicationName)
fi

sed -i 's|dhc_application_name|'$APPLICATION_NAME'|' $TELEGRAF_CONF_FILE

echo "-----> Application Name in Graphite: '$APPLICATION_NAME'"

if [ -z ${GRAPHITE_URL+x} ]; 
then 
  export GRAPHITE_URL=$(getGraphiteUrl)
fi

if [ -z ${GRAPHITE_PORT+x} ]; 
then 
  export GRAPHITE_PORT=$(getGraphitePort)
fi

if [ ${GRAPHITE_URL} == "null" ]; then
  echo "       **ERROR** No Graphite configuration found in Services!"
  echo "                 Please add the a9s_Prometheus Service to use this buildpack!"
  exit 1
fi

sed -i 's/localhost:2003/'$GRAPHITE_URL':'$GRAPHITE_PORT'/' $TELEGRAF_CONF_FILE

echo "-----> GraphiteURL: '$GRAPHITE_URL:$GRAPHITE_PORT'"


if [ -z ${NO_PROM+x} ]; 
then 

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

else

  sed -i 's|[[inputs.prometheus]]|# [[inputs.prometheus]]|' $TELEGRAF_CONF_FILE
  sed -i 's|"urls = [\"http://localhost:9100/metrics\"]"|"# urls = [\"http://localhost:9100/metrics\"]"|' $TELEGRAF_CONF_FILE
  # sed -i 's|[[inputs.prometheus]]|'\# [[inputs.prometheus]]'|' $TELEGRAF_CONF_FILE

fi