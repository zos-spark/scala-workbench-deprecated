#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source config

WORKBOOK_PORT=$WORKBOOK_PORT WORKBOOK_NAME=$WORKBOOK_NAME WORKBOOK_VOLUME=$WORKBOOK_VOLUME \
  docker-compose -f $DIR/docker-compose.yml -p $WORKBOOK_NAME up -d
