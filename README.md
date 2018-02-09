# README

This project provides a Docker image for a standalone StreamSets Data Collector (SDC)
preconfigured with  HortonWorks hadoop-client libraries for use within an Azure 
environment to connect to HDInsights clusters

The image uses Docker Volumes for data persistence

## Configuration

Set the SDC Version:

	$ export SDC_VERSION=3.1.0.0

Set the location where SDC will be installed:

	$ export SDC_DIST=/opt/streamsets-datacollector-$SDC_VERSION


## Build:

	$ docker build -t mbrooks/datacollector:$SDC_VERSION .


## Create a Data Container with multiple Docker Volumes 

This command creates a Docker Data Container named "sdc-volumes" 
with multiple data volumes so that important SDC data and configs 
persist across container restarts and upgrades

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
	mbrooks/datacollector:$SDC_VERSION



## Running a container
# Run the custom SDC using the data container
$ docker run \
 --volumes-from sdc-volumes \
 -p 18630:18630  \
 --add-host="headnodehost:$HEAD_NODE_HOST" \
 -d mark/datacollector:$SDC_VERSION dc 
 
 
 
# Connect in bash 
$ docker exec -it 581fa67c4b34 bash

docker run  -p 18630:18630 -d mark/datacollector:3.1.0.0 dc 

