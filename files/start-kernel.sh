#!/bin/bash
# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.


cat /home/jovyan/kernel.json.template | sed "s/TMP_SPARK_HOST/${SPARK_HOST}/g;s/TMP_SPARK_PORT/${SPARK_PORT}/g;s/TMP_SPARK_CPUS/$SPARK_CPUS/g;s/TMP_SPARK_MEM/$SPARK_MEM/g" > /home/$NB_USER/kernel.json

start-notebook.sh --port=${WORKBOOK_PORT}
