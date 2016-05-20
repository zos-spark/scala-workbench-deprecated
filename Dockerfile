# (c) Copyright IBM Corp. 2016.  All Rights Reserved.
# Distributed under the terms of the Modified BSD License.

FROM jupyter/minimal-notebook:2d878db5cbff

MAINTAINER zos-spark/zspeak-dev

USER root

# Setup Java
RUN mkdir -p /opt/ibm/java
COPY ibm-java-x86_64-sdk-8.0-2.10.bin /opt/ibm/java/ibm-java-x86_64-sdk-8.0-2.10.bin
COPY installer.properties /opt/ibm/java/installer.properties
RUN chmod -R 755 /opt/ibm/java
WORKDIR /opt/ibm/java
RUN ./ibm-java-x86_64-sdk-8.0-2.10.bin -r installer.properties
RUN rm -Rf /usr/lib/jvm/default-java
RUN mkdir -p /usr/lib/jvm/default-java
RUN ln -s /opt/ibm/java/* /usr/lib/jvm/default-java
RUN update-alternatives --install "/usr/bin/javac" "javac" "/usr/lib/jvm/default-java/bin/javac" 9999
RUN update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/default-java/bin/java" 9999
RUN update-alternatives --set java /usr/lib/jvm/default-java/bin/java

# Spark dependencies
ENV APACHE_SPARK_VERSION 1.5.2
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends && \
    apt-get clean
RUN wget -qO - http://d3kbcqa49mib13.cloudfront.net/spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop2.6 spark

# Mesos dependencies
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    DISTRO=debian && \
    CODENAME=wheezy && \
    echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-get -y update && \
    apt-get --no-install-recommends -y --force-yes install mesos=0.22.1-1.0.debian78 && \
    apt-get clean

# System-z Patch for Spark libs
RUN mkdir -p /opt/sparkkernel
#  - First, we need to use a spark kernel built on zOS
#COPY spark-kernel-0.1.5-SNAPSHOT_zOS.zip /opt/ibm/zspark_skmaster/spark-kernel-0.1.5-SNAPSHOT_zOS.zip
RUN wget -q https://github.com/zos-spark/scala-workbench/releases/download/v1.0.0/spark-kernel-0.1.5-SNAPSHOT_zOS.zip
RUN unzip spark-kernel-0.1.5-SNAPSHOT_zOS.zip -d /opt/ibm/zspark_skmaster/
RUN rm spark-kernel-0.1.5-SNAPSHOT_zOS.zip

# - Secondly, we will replace Spark stack w/Spark-Assembly jar files from zOS Build
COPY spark-assembly-1.5.2-hadoop2.6.0.jar /opt/ibm/zspark_skmaster/spark-kernel/lib/spark-assembly-1.5.2-hadoop2.6.0.jar

# Scala Spark kernel (build and cleanup)
RUN mv /opt/ibm/zspark_skmaster/spark-kernel/* /opt/sparkkernel/
RUN chmod +x /opt/sparkkernel
RUN chmod +x /opt/sparkkernel/bin/spark-kernel

# Spark and Mesos pointers
ENV SPARK_HOME /usr/local/spark
ENV R_LIBS_USER $SPARK_HOME/R/lib
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.8.2.1-src.zip
ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so

USER jovyan

# Install Python 3 packages
RUN conda install --yes \
  'ipywidgets=4.1*' \
  'pandas=0.17*' \
  'matplotlib=1.5*' \
  'scipy=0.17*' \
  'seaborn=0.7*' \
  'scikit-learn=0.17*' \
   && conda clean -yt

# Install Python 2 packages and kernel spec
RUN conda create -p $CONDA_DIR/envs/python2 python=2.7 \
  'ipython=4.1*' \
  'ipywidgets=4.1*' \
  'pandas=0.17*' \
  'matplotlib=1.5*' \
  'scipy=0.17*' \
  'seaborn=0.7*' \
  'scikit-learn=0.17*' \
  pyzmq \
  && conda clean -yt

# Scala Spark kernel spec
RUN mkdir -p /opt/conda/share/jupyter/kernels/scala
COPY kernel.json /opt/conda/share/jupyter/kernels/scala/


USER root

# Install npm and bower
    #ln -s /usr/bin/nodejs /usr/bin/node && \
RUN apt-get update && \
    apt-get install -y curl && \
    curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash - && \
    apt-get install --yes nodejs && \
    npm install -g bower

# Do the pip installs as the unprivileged notebook user
USER jovyan

# Install dashboard layout and preview within Jupyter Notebook
RUN pip install jupyter_dashboards && \
  jupyter dashboards install --user --symlink && \
  jupyter dashboards activate

# Install declarative widgets for Jupyter Notebook
RUN pip install jupyter_declarativewidgets==0.3.0 && \
  jupyter declarativewidgets install --user --symlink && \
  jupyter declarativewidgets activate

# Install content management to support dashboard bundler options
RUN pip install jupyter_cms && \
  jupyter cms install --user --symlink && \
  jupyter cms activate
RUN pip install jupyter_dashboards_bundlers && \
  jupyter dashboards_bundlers activate

RUN pip install pymongo

USER root
# Reset Working Directory
WORKDIR /home/$NB_USER/work

USER jovyan
