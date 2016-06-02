#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source config

if [ -z "${SPARK_HOST:+x}" ]; then
  echo "Error: SPARK_HOST is not set"
  exit 1
fi

docker volume create --name $WORKBOOK_VOLUME

WORKBOOK_PORT=$WORKBOOK_PORT WORKBOOK_NAME=$WORKBOOK_NAME WORKBOOK_VOLUME=$WORKBOOK_VOLUME \
  SPARK_PORT=$SPARK_PORT SPARK_HOST=$SPARK_HOST \
  docker-compose -f $DIR/docker-compose.yml -p $WORKBOOK_NAME up -d
