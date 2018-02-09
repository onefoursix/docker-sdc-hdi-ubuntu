#
# Copyright 2018 StreamSets Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

######################################
## Dockerfile to build a standalone instance of SDC pre-configured 
## with the Hortonworks hadoop-client libs to facilitate interaction 
## with Azure HDI Clusters
##
## This project borrowed heavily from the project here (thanks Adam!):
## https://github.com/streamsets/datacollector-docker
######################################
FROM ubuntu:16.04
LABEL maintainer="Mark Brooks <mark@streamsets.com>"


######################################
## SDC version and download location
######################################
ARG SDC_VERSION=3.1.0.0
ARG SDC_URL=http://nightly.streamsets.com.s3-us-west-2.amazonaws.com/datacollector/3.1/3.1.0.0-RC2/tarball/streamsets-datacollector-core-3.1.0.0.tgz


######################################
## Install Dependencies:
##
## - OpenJDK8
## - curl
##  
## Note that OpenJDK 1.8.0.161 (the current default for Ubuntu 16.04) allows strong crypto by default
######################################
RUN apt-get update && apt-get install -y \
  default-jdk \
  curl



######################################
## Install HortonWorks hadoop-client
######################################  
COPY resources/etc.apt.sources.list.d/HDP.list /etc/apt/sources.list.d/
RUN apt-get update && apt-get install -y --allow-unauthenticated hadoop-client



######################################
## Set the SDC User
## We set a UID/GID for the SDC user because certain  environments 
## require these to be consistent throughout the cluster. 
## We use 20159 because it's above the default value of YARN's min.user.id property.
######################################
ARG SDC_USER=sdc
ARG SDC_UID=20159


######################################
## The paths below should generally be attached to a VOLUME for persistence.
## See the project's README.md for example use of VOLUMEs
##
## SDC_CONF is where configuration files are stored. This can be shared.
## SDC_DATA is a volume for storing collector state. Do not share this between containers.
## SDC_LOG is an optional volume for file based logs.
## SDC_RESOURCES is where resource files such as runtime:conf resources and Hadoop configuration can be placed.
## STREAMSETS_LIBRARIES_EXTRA_DIR is where extra libraries such as JDBC drivers should go.
## USER_LIBRARIES_DIR is where custom stage libraries are installed.
######################################
ENV SDC_DIST="/opt/streamsets-datacollector-${SDC_VERSION}"
ENV SDC_CONF=/etc/sdc \
    SDC_DATA=/data \
    SDC_LOG=/logs \
    SDC_RESOURCES=/resources \
    USER_LIBRARIES_DIR=/sdc-user-libs \
    STREAMSETS_LIBRARIES_EXTRA_DIR="${SDC_DIST}/streamsets-libs-extras"


######################################
## Run the SDC configuration script
######################################
COPY scripts/sdc-configure.sh /
RUN /sdc-configure.sh && rm /sdc-configure.sh


######################################
## Load the HDI Hadoop configs into /etc
######################################
RUN rm -rf /etc/hadoop/conf/*
RUN rm -rf /etc/hive/conf/*
COPY resources/etc.hadoop.conf/* /etc/hadoop/conf/
COPY resources/etc.hive.conf/* /etc/hive/conf/


######################################
## Load the HDI Hadoop configs into SDC Resources
######################################
COPY resources/etc.hive.conf ${SDC_RESOURCES}/hadoop-conf
COPY resources/etc.hive.conf ${SDC_RESOURCES}/hive-conf


######################################
## Load the HDI certs and decrypt utility
## which lets SDC read encrypted storage keys
## in core-site.xml
######################################
COPY resources/hdinsight-common /usr/lib/hdinsight-common


######################################
## Launch SDC
######################################
USER ${SDC_USER}
EXPOSE 18630
COPY scripts/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]



