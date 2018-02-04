#
# Copyright 2017 StreamSets Inc.
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
#

#
# Copyright 2017 StreamSets Inc.
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
#

FROM ubuntu:16.04
LABEL maintainer="Mark Brooks <mark@streamsets.com>"

# SDC Version
ARG SDC_VERSION=3.1.0.0

# SDC tarball download URL
ARG SDC_URL=http://nightly.streamsets.com.s3-us-west-2.amazonaws.com/datacollector/3.1/3.1.0.0-RC2/tarball/streamsets-datacollector-core-3.1.0.0.tgz

RUN apt-get update

RUN apt-get -y install curl

# JDK installation
# (Note that Open JDK 1.8.0.161 allows strong crypto by default)
RUN apt-get -y install default-jdk



ARG SDC_USER=sdc

# We set a UID/GID for the SDC user because certain test environments require these to be consistent throughout
# the cluster. We use 20159 because it's above the default value of YARN's min.user.id property.
ARG SDC_UID=20159


   

# Begin Data Collector installation



# The paths below should generally be attached to a VOLUME for persistence.
# SDC_CONF is where configuration files are stored. This can be shared.
# SDC_DATA is a volume for storing collector state. Do not share this between containers.
# SDC_LOG is an optional volume for file based logs.
# SDC_RESOURCES is where resource files such as runtime:conf resources and Hadoop configuration can be placed.
# STREAMSETS_LIBRARIES_EXTRA_DIR is where extra libraries such as JDBC drivers should go.
# USER_LIBRARIES_DIR is where custom stage libraries are installed.
ENV SDC_CONF=/etc/sdc \
    SDC_DATA=/data \
    SDC_DIST="/opt/streamsets-datacollector-${SDC_VERSION}" \
    SDC_LOG=/logs \
    SDC_RESOURCES=/resources \
    USER_LIBRARIES_DIR=/opt/streamsets-datacollector-user-libs
ENV STREAMSETS_LIBRARIES_EXTRA_DIR="${SDC_DIST}/streamsets-libs-extras"


# SDC Version
ARG SDC_VERSION=3.1.0.0

# SDC tarball download URL
ARG SDC_URL=http://nightly.streamsets.com.s3-us-west-2.amazonaws.com/datacollector/3.1/3.1.0.0-RC2/tarball/streamsets-datacollector-core-3.1.0.0.tgz


# Run the SDC configuration script.
COPY sdc-configure.sh /
RUN /sdc-configure.sh && rm /sdc-configure.sh

USER ${SDC_USER}
EXPOSE 18630
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]



