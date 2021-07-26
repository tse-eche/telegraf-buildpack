#!/bin/bash

set -euo pipefail

DEPS_DIR=$1
DEPS_IDX=$2

echo "-----> Configuring $SIDECAR_NAME Sidecar"

TELEGRAF_CONF_FILE=$DEPS_DIR/$DEPS_IDX/telegraf/telegraf.conf
NO_GRAPHITE="false";

getOrganizationName()
{
    echo $(echo $VCAP_APPLICATION | jq -r '.organization_name')
}

getSpaceName()
{
    echo $(echo $VCAP_APPLICATION | jq -r '.space_name')
}

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

if [ -z ${ORGANIZATION_NAME+x} ]; 
then 
  export ORGANIZATION_NAME=$(getOrganizationName)
fi

if [ -z ${SPACE_NAME+x} ]; 
then 
  export SPACE_NAME=$(getSpaceName)
fi

if [ -z ${APPLICATION_NAME+x} ]; 
then 
  export APPLICATION_NAME=$(getApplicationName)
fi

sed -i 's|dhc_organization_name|'$ORGANIZATION_NAME'|' $TELEGRAF_CONF_FILE
sed -i 's|dhc_space_name|'$SPACE_NAME'|' $TELEGRAF_CONF_FILE
sed -i 's|dhc_application_name|'$APPLICATION_NAME'|' $TELEGRAF_CONF_FILE

echo "-----> Application Name in Graphite: '$APPLICATION_NAME'"
echo "-----> Full Qualified Application Name in Graphite: '$ORGANIZATION_NAME.$SPACE_NAME.$APPLICATION_NAME'"

if [ -z ${GRAPHITE_HOST+x} ]; 
then 
  export GRAPHITE_HOST=$(getGraphiteUrl)
fi

if [ -z ${GRAPHITE_PORT+x} ]; 
then 
  export GRAPHITE_PORT=$(getGraphitePort)
fi

if [ ${GRAPHITE_HOST} == "null" ]; then
  echo "       **ERROR** No Graphite configuration found in Services!"
  echo "                 Please add the a9s_Prometheus Service to use this buildpack,"
  echo "                 or define 'GRAPHITE_HOST' and 'GRAPHITE_PORT' as environment varaible!"
  NO_GRAPHITE="true";
fi

if [ ${NO_GRAPHITE} == "false" ]; then
  sed -i 's|localhost:2003|'$GRAPHITE_HOST':'$GRAPHITE_PORT'|' $TELEGRAF_CONF_FILE

  echo "-----> GraphiteURL: '$GRAPHITE_HOST:$GRAPHITE_PORT'"
else
  sed -i 's|\[\[outputs.graphite\]\]|# \[\[outputs.graphite\]\]|' $TELEGRAF_CONF_FILE
  sed -i 's| servers = \[\"localhost:2003\"\]|# servers = \[\"localhost:2003\"\]|' $TELEGRAF_CONF_FILE
  sed -i 's| graphite_tag_support = true|# graphite_tag_support = true|' $TELEGRAF_CONF_FILE
  sed -i 's| graphite_separator = "."|# graphite_separator = "."|' $TELEGRAF_CONF_FILE

  echo "-----> Skip Graphite Configuration"
  echo "-----> Set STDOUT Configuration"

  sed -i 's|# \[\[outputs.file\]\]|\[\[outputs.file\]\]|' $TELEGRAF_CONF_FILE
  sed -i 's|# files = \[\"stdout\"\]|files = \[\"stdout\"\]|' $TELEGRAF_CONF_FILE
  sed -i 's|# data_format = \"graphite\"|data_format = \"graphite\"|' $TELEGRAF_CONF_FILE
fi

if [ -z ${NO_PROM+x} ]; 
then 
  export NO_PROM="true";
fi

if [ ${NO_PROM} == "true" ]; 
then 

  sed -i 's|\[\[inputs.prometheus\]\]|# \[\[inputs.prometheus\]\]|' $TELEGRAF_CONF_FILE
  sed -i 's|urls = \[\"http://localhost:9100/metrics\"\]|# urls = \[\"http://localhost:9100/metrics\"\]|' $TELEGRAF_CONF_FILE
  sed -i 's| metric_version = 2|# metric_version = 2|' $TELEGRAF_CONF_FILE

  echo "-----> Skip Prometheus Configuration"

else

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
    export PROM_PATH="/metrics"
  fi

  sed -i 's|localhost:9100/metrics|'$PROM_HOST':'$PROM_PORT$PROM_PATH'|' $TELEGRAF_CONF_FILE

  echo "-----> Prometheus-URL: '$PROM_HOST:$PROM_PORT$PROM_PATH'"

fi