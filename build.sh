#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

source config

if [ -z "$SPARK_HOST" ]; then
  echo "Error: SPARK_HOST is not set"
  exit 1
elif [ -z "$SPARK_PORT" ]; then
  echo "Error: SPARK_PORT is not set"
  exit 1
elif [ -z "$WORKBOOK_NAME" ]; then
  echo "Error: SWORKBOOK_NAME is not set"
  exit 1
elif [ -z "$WORKBOOK_PORT" ]; then
  echo "Error: WORKBOOK_PORT is not set"
  exit 1
fi

FILES=template/*.template

for f in $FILES; do
  f_clean=`echo $f | sed 's/template\///g;s/.template//g'`
  cat $f | sed "s/TMP_SPARK_HOST/$SPARK_HOST/g;s/TMP_SPARK_PORT/$SPARK_PORT/g;s/TMP_WORKBOOK_NAME/$WORKBOOK_NAME/g;s/TMP_WORKBOOK_PORT/$WORKBOOK_PORT/g" > $f_clean
done

docker-compose build
