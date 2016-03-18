#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

CONTAINER_ID=`source config ; docker ps | grep " $WORKBOOK_NAME" | awk '{print $1}'`

docker exec -it $CONTAINER_ID /bin/bash
