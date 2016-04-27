#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${SPARK_HOST:+x}" ]; then
  echo "Error: SPARK_HOST is not set"
  exit 1
fi

SPARK_PORT=${SPARK_PORT:=7077}

FILES="$DIR/template/*.template"

for f in $FILES; do
  f_clean=`echo $f | sed 's/template\///g;s/.template//g'`
  cat $f | sed "s/TMP_SPARK_HOST/$SPARK_HOST/g;s/TMP_SPARK_PORT/$SPARK_PORT/g" > $f_clean
done

docker-compose build
