ARG UBUNTU_VERSION=20.04

FROM ubuntu:${UBUNTU_VERSION}
LABEL maintainer="birkholz@cubert-gmbh.de"

ARG UBUNTU_VERSION
ARG CUVIS_VERSION=3.3.1
ARG CUVIS_MINOR_V=3.3

### Avoid installer user interaction
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install git wget unzip -y
	
RUN mkdir cuvis_tmp && cd cuvis_tmp && \
    wget https://cloud.cubert-gmbh.de/s/qpxkyWkycrmBK9m/download -q && \
    unzip -q download && \
    cd  "Cuvis ${CUVIS_MINOR_V}/Cuvis ${CUVIS_VERSION}/Ubuntu ${UBUNTU_VERSION}-amd64-nocuda" && \
    apt-get install ./cuviscommon_${CUVIS_VERSION}-1.deb -y && \
    apt-get install ./libcuvis_${CUVIS_VERSION}-1.deb -y && \
    cd / && \
    rm -r /cuvis_tmp
	
ENV CUVIS=/lib/cuvis
