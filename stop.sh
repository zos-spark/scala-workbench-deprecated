#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

export WORKBOOK_NAME=${WORKBOOK_NAME:=scala-workbench}

docker-compose -p "$WORKBOOK_NAME" down
