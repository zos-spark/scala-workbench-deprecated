#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# handle config files
if [ ! -z "$1" ]; then
  if [ ! -f $1 ]; then
        echo "File not found!"
        exit 1
  else 
    source $1
  fi
else 
  source $DIR/config
fi

if [ -z "${SPARK_HOST:+x}" ]; then
  echo "Error: SPARK_HOST is not set"
  exit 1
fi
if [ -z "${PASSWORD:+x}" ]; then
  echo "Error: PASSWORD is not set"
  exit 1
fi

docker volume create --name $WORKBOOK_VOLUME

WORKBOOK_PORT=$WORKBOOK_PORT WORKBOOK_NAME=$WORKBOOK_NAME WORKBOOK_VOLUME=$WORKBOOK_VOLUME WORKBOOK_DEBUG=$WORKBOOK_DEBUG \
  SPARK_PORT=$SPARK_PORT SPARK_HOST=$SPARK_HOST SPARK_CPUS=$SPARK_CPUS SPARK_MEM=$SPARK_MEM SPARK_USER=$SPARK_USER \
  PASSWORD=$PASSWORD \
  docker-compose -f $DIR/docker-compose.yml -p $WORKBOOK_NAME up -d

cat $DIR/files/kernel.json.template | sed "s/TMP_SPARK_HOST/${SPARK_HOST}/g;s/TMP_SPARK_PORT/${SPARK_PORT}/g;s/TMP_SPARK_CPUS/$SPARK_CPUS/g;s/TMP_SPARK_MEM/$SPARK_MEM/g;s/TMP_SPARK_USER/$SPARK_USER/g" > $DIR/files/kernel.json.${WORKBOOK_NAME}
docker cp $DIR/files/kernel.json.${WORKBOOK_NAME} ${WORKBOOK_NAME}:/opt/conda/share/jupyter/kernels/scala/kernel.json
