# README

This project provides an Ubuntu-based Docker image for a standalone StreamSets Data 
Collector (SDC) preconfigured with  HortonWorks hadoop-client libraries for use within 
an Azure environment to connect to HDInsights (HDI) clusters

Info on StreamSets Data Collector is [here](https://streamsets.com/products/sdc)

The image uses Docker Volumes for data persistence

## Required Resources

In order to connect to a specific HDI cluster, several artifacts need to be 
copied to this project's resources directory before creating the image, as described below: 

#### HDI Hadoop Config Files

Copy the directory `/etc/hadoop/conf` from one of the nodes on the target 
HDI Cluster to this project's `resources/etc.hadoop.conf` directory

#### HDI Hive Config Files

Copy the directory `/etc/hive/conf` from one of the nodes on the target HDI 
Cluster to this project's `resources/etc.hive.conf` directory

#### HortonWorks Repo List

The hadoop client libs installed on the SDC node must precisely match those in use 
on the HDI cluster.  To ensure that, copy the file `/etc/apt/sources.list.d/HDP.list` 
from one of the nodes on the target HDI Cluster to this project's
`resources/etc.apt.sources.list.d` directory

#### HDInsights Common Certs and Scripts

In order to read encrypted Azure Storage Account keys from the HDI cluster's 
 `core-site.xml` config file, the HDI Cluster's certs and `decrypt.sh` script are needed.
 
Copy the directories `/usr/lib/hdinsight-common/certs` and 
`/usr/lib/hdinsight-common/scripts` from one of the nodes on the target HDI 
Cluster to this project's `resources/hdinsight-common` directory

An alternative would be to replace the encrypted Storage Account keys 
in `core-site.xml` with plain-text keys and to remove the property
`fs.azure.account.keyprovider.<YOUR_STORAGE_ACCOUNT>.blob.core.windows.net` from 
`core-site.xml`.   I prefer leaving the encrypted keys in place to avoid having 
plain-text keys in the config files




## Environment Variables

Set the SDC Version:

	$ export SDC_VERSION=3.1.0.0

Set the path where SDC will be installed:

	$ export SDC_DIST=/opt/streamsets-datacollector-$SDC_VERSION

Set the IP Address for the HDI Cluster's "headnodehost"
(You can get this address by pinging `headnodehost` from one of the nodes on the 
HDI target cluster).  

	$ export HEAD_NODE_HOST=<headnodehost IP address>
	
For example, if the headnode host IP address is 172.16.0.11 the command would look like this:

	$ export HEAD_NODE_HOST=172.16.0.11
	
## Build

Build the Docker Container:

	$ docker build -t mbrooks/datacollector:$SDC_VERSION .


## Create a data container 

This command creates a Docker data container named "sdc-volumes" 
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
Run the container with the following command which references the data container and the 
headnodehost IP address and exposes the SDC port:

 
	$ docker run \
	 --volumes-from sdc-volumes \
	 -p 18630:18630  \
	 --add-host="headnodehost:$HEAD_NODE_HOST" \
	 -d mbrooks/datacollector:$SDC_VERSION dc 
 
 ## Connect to SDC
 You should be able to connect to SDC at http://\<docker-host\>:18630
 
 
 
 
 
 

