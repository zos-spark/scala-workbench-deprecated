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

WORKBOOK_PORT=$WORKBOOK_PORT WORKBOOK_NAME=$WORKBOOK_NAME WORKBOOK_VOLUME=$WORKBOOK_VOLUME WORKBOOK_DEBUG=$WORKBOOK_DEBUG \
  SPARK_PORT=$SPARK_PORT SPARK_HOST=$SPARK_HOST SPARK_CPUS=$SPARK_CPUS SPARK_MEM=$SPARK_MEM SPARK_USER=$SPARK_USER \
  PASSWORD=$PASSWORD \
  docker-compose -f $DIR/docker-compose.yml -p $WORKBOOK_NAME down
