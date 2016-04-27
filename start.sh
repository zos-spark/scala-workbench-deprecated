#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

export WORKBOOK_NAME=${WORKBOOK_NAME:=scala-workbench}

export WORKBOOK_PORT=${WORKBOOK_PORT:=8888}

docker-compose -p "$WORKBOOK_NAME" up -d
