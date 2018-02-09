# README

This project provides an Ubuntu-based Docker image for a standalone StreamSets Data 
Collector (SDC) preconfigured with  HortonWorks hadoop-client libraries for use within 
an Azure environment to connect to HDInsights clusters

Info on StreamSets Data Collector is [here](https://streamsets.com/products/sdc)

The image uses Docker Volumes for data persistence

## Configuration

Set the SDC Version:

	$ export SDC_VERSION=3.1.0.0

Set the location where SDC will be installed:

	$ export SDC_DIST=/opt/streamsets-datacollector-$SDC_VERSION


## Required Resources

There are a number of artifacts that need to be added to this project's resources
directory before creating the image.  These artifacts should be copied from the
Azure HDInsights cluster node SDC will connect to to the appropriate directories
within this project as described below:


#### HortonWorks Repo List

Copy the file `/etc/apt/sources.list.d/HDP.list` from an HDInsights Cluster node 
to this project's `resources/etc.apt.sources.list` directory

#### HDInsights Common Certs and Scripts

In order to read encrypted Azure Storage Account keys from the HDInsights hadoop
config file core-site.xml, the HDInsights Cluster certs and decrypt.sh script need 
to be copied to this project. 

Copy the directories `/usr/lib/hdinsight-common/certs` and 
`/usr/lib/hdinsight-common/scripts` from one of the target HDInsights Cluster's nodes 
to this project's `resources/hdinsight-common` directory

#### HDInsights Hadoop Config Files

Copy the directories `/etc/hadoop/conf` from one of the target HDInsights Cluster's nodes
to this project's `resources/etc.hadoop.conf` directory

#### HDInsights Hive Config Files

Copy the directories `/etc/hive/conf` from one of the target HDInsights Cluster's nodes
to this project's `resources/etc.hive.conf` directory



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

