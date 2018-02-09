# README

This project provides an Ubuntu-based Docker image for a standalone StreamSets Data 
Collector (SDC) preconfigured with  HortonWorks hadoop-client libraries for use within 
an Azure environment to connect to HDInsights clusters

Info on StreamSets Data Collector is [here](https://streamsets.com/products/sdc)

The image uses Docker Volumes for data persistence

## Required Resources

There are a number of artifacts that need to be added to this project's resources
directory before creating the image.  These artifacts should be copied from the
Azure HDInsights cluster node SDC will connect to to the appropriate directories
within this project as described below:

#### HortonWorks Repo List

Copy the file `/etc/apt/sources.list.d/HDP.list` from one of the nodes on the target 
HDInsights Cluster to this project's `resources/etc.apt.sources.list` directory

#### HDInsights Common Certs and Scripts

In order to read encrypted Azure Storage Account keys from the HDInsights hadoop
config file `core-site.xml`, the HDInsights Cluster certs and `decrypt.sh` script be 
copied to this project.  An alternative would be to replace the encrypted Storage 
Account keys in `core-site.xml` with plain-text keys and to remove the property
`fs.azure.account.keyprovider.<YOUR_STORAGE_ACCOUNT>.blob.core.windows.net` from 
`core-site.xml`.   I prefer leaving the encrypted keys in place to avoid having 
plain-text keys lying around

Copy the directories `/usr/lib/hdinsight-common/certs` and 
`/usr/lib/hdinsight-common/scripts` from one of the nodes on the target HDInsights 
Cluster to this project's `resources/hdinsight-common` directory

#### HDInsights Hadoop Config Files

Copy the directory `/etc/hadoop/conf` from one of the nodes on the target 
HDInsights Cluster to this project's `resources/etc.hadoop.conf` directory

#### HDInsights Hive Config Files

Copy the directory `/etc/hive/conf` from one of the nodes on the target HDInsights 
Cluster to this project's `resources/etc.hive.conf` directory


## Environment Variables

Set the SDC Version:

	$ export SDC_VERSION=3.1.0.0

Set the location where SDC will be installed:

	$ export SDC_DIST=/opt/streamsets-datacollector-$SDC_VERSION

Set the IP Address for the HDInsights Cluster's "headnodehost"
(You can get this address by pinging headnodehost from one of the nodes on the 
HDInsights target cluster)

	$ export HEAD_NODE_HOST=172.16.0.11


## Build

Build the Docker Container:

	$ docker build -t mbrooks/datacollector:$SDC_VERSION .


## Create a Data Container with multiple Docker Volumes 

This command creates a Docker Data Container named "sdc-volumes" 
with multiple data volumes so that important SDC data and configs 
persist across container restarts and upgrades

	$ docker create \
	 -v /etc/sdc \
	 -v /data \
	 -v $SDC_DIST/streamsets-libs \
	 -v /resources \
	 -v /opt/streamsets-datacollector-user-libs \
	 -v $SDC_DIST/streamsets-libs-extras \
	 -v /logs \
	 --name sdc-volumes \
	mbrooks/datacollector:$SDC_VERSION



## Run the container
Run the container with the following command to expose the SDC port and passing 
in the cluster's headnodehost
 
	$ docker run \
	 --volumes-from sdc-volumes \
	 -p 18630:18630  \
	 --add-host="headnodehost:$HEAD_NODE_HOST" \
	 -d mbrooks/datacollector:$SDC_VERSION dc 
 
 

