# Python Version 3.9.x to able to support OFT without any issues
FROM python:3.9.21-bullseye AS spark-base

ARG SPARK_VERSION=3.5.3

# Install tools required by the OS
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        sudo \
        curl \
        vim \
        unzip \
        rsync \
        openjdk-11-jdk \
        build-essential \
        software-properties-common \
        ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Setup the directories for our Spark and Hadoop installations
ENV SPARK_HOME=${SPARK_HOME:-"/opt/spark"}
ENV HADOOP_HOME=${HADOOP_HOME:-"/opt/hadoop"}

RUN mkdir -p ${HADOOP_HOME} && mkdir -p ${SPARK_HOME}
WORKDIR ${SPARK_HOME}

# Download and install Spark
RUN curl https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz -o spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && tar xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz --directory /opt/spark --strip-components 1 \
    && rm -rf spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Setting up pyspark base
FROM spark-base AS pyspark-base

## Install python deps
COPY requirements/requirements.txt .
RUN pip3 install -r requirements.txt


# Creating pyspark image
FROM pyspark-base AS pyspark

## Setup Spark related environment variables
ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_MASTER="spark://spark-master:7077"
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

## Copy the default configurations into $SPARK_HOME/conf
COPY spark-conf/spark-defaults.conf "$SPARK_HOME/conf"

## Making binaries and scripts executable
RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*
ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

## Copy appropriate entrypoint script
COPY --chmod=755 entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]

# Setting up Jupyter notebook for Dev..
# Maybe remove this if VS Code Jupyter node can be connected to master running on docker
FROM pyspark-base AS jupyter-notebook

ARG JUPYTERLAB_VERSION=4.3.4

ENV SPARK_MASTER="spark://spark-master:7077"
# ENV SPARK_REMOTE="spark://spark-master:7077"

RUN mkdir /opt/notebooks
RUN mkdir /opt/extra-jars

RUN apt-get update -y && \
    apt-get install -y iputils-ping && \
    apt-get install -y python3-pip python3-dev && \
    pip3 install --upgrade pip && \
    pip3 install wget jupyterlab==${JUPYTERLAB_VERSION}


WORKDIR /opt/notebooks

# Non-secured -- no token values passed -- for local dev
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=