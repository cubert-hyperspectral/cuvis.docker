ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION}
LABEL maintainer="birkholz@cubert-gmbh.de"

SHELL ["/bin/bash", "-lc"]
ARG UBUNTU_VERSION
ARG CUVIS_VERSION=3.5.3

### Avoid installer user interaction
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && \
    apt-get install git wget unzip ca-certificates gpg build-essential -y
	
WORKDIR /tmp
	
RUN mkdir cuvis && cd cuvis && \
    wget https://cloud.cubert-gmbh.de/s/cuvis_sdk_release_ver_${CUVIS_VERSION//./}/download -q -O download && \
    unzip -q download && \
    cd  "Cuvis ${CUVIS_VERSION}/Ubuntu ${UBUNTU_VERSION}-amd64-nocuda" && \
    apt-get install ./cuviscommon_${CUVIS_VERSION}-0.deb -y && \
    apt-get install ./libcuvis_${CUVIS_VERSION}-0.deb -y && \
    cd /tmp && \
    rm -rf ./cuvis

## Adding newest cmake version
RUN apt-get install -y --no-install-recommends && \
    wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc \
        | gpg --dearmor - > /usr/share/keyrings/kitware-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] \
        https://apt.kitware.com/ubuntu/ $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
        > /etc/apt/sources.list.d/kitware.list && \
    apt-get update && apt-get install -y --no-install-recommends cmake && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
	
ENV CUVIS=/lib/cuvis
