# README for the docker-sdc-hdi-ubuntu Docker Image

This image includes StreamSets Data Collector preconfigured with the HortonWorks 
hadoop-client

$ export SDC_VERSION=3.1.0.0
$ export SDC_DIST=/opt/streamsets-datacollector-$SDC_VERSION
$ export HEAD_NODE_HOST=111.111.111.111


# Build
$ docker build -t mark/datacollector:$SDC_VERSION .



# Create a data container with volumes for data, configs, streamsets-libs, 
# resources, user-libs, extras and logs:

$ docker create \
 -v /etc/sdc \
 -v /etc/apt/sources.list.d \
 -v /data \
 -v $SDC_DIST/streamsets-libs \
 -v /resources \
 -v /opt/streamsets-datacollector-user-libs \
 -v /sdc-libs-extras \
 -v $SDC_DIST/streamsets-libs-extras \
 -v /logs \
 -v /usr/lib/hdinsight-common \
 --name sdc-volumes \
 mark/datacollector:$SDC_VERSION


# Run the custom SDC using the data container
$ docker run \
 --volumes-from sdc-volumes \
 -p 18630:18630  \
 --add-host="headnodehost:$HEAD_NODE_HOST" \
 -d mark/datacollector:$SDC_VERSION dc 
 
 
 
# Connect in bash 
$ docker exec -it 581fa67c4b34 bash

docker run  -p 18630:18630 -d mark/datacollector:3.1.0.0 dc 

