ARG UBUNTU_VERSION=24.04

FROM ubuntu:${UBUNTU_VERSION}
LABEL maintainer="birkholz@cubert-gmbh.de"

ARG UBUNTU_VERSION
ARG CUVIS_VERSION=3.3.3
ARG CUVIS_MINOR_V=3.3

### Avoid installer user interaction
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && \
    apt-get install git wget unzip -y
	
WORKDIR /tmp
	
RUN mkdir cuvis && cd cuvis && \
    wget https://cloud.cubert-gmbh.de/s/qpxkyWkycrmBK9m/download -q && \
    unzip -q download && \
    cd  "Cuvis ${CUVIS_MINOR_V}/Cuvis ${CUVIS_VERSION}/Ubuntu ${UBUNTU_VERSION}-amd64-nocuda" && \
    apt-get install ./cuviscommon_${CUVIS_VERSION}-1.deb -y && \
    apt-get install ./libcuvis_${CUVIS_VERSION}-1.deb -y && \
    cd /tmp && \
    rm -rf ./cuvis
	
ENV CUVIS=/lib/cuvis
