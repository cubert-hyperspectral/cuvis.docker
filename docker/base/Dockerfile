ARG UBUNTU_VERSION=20.04
ARG CUVIS_VERSION=3.3.0
ARG CUVIS_MINOR_V=3.3

FROM ubuntu:${UBUNTU_VERSION}
LABEL maintainer="birkholz@cubert-gmbh.de"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install git wget unzip curl -y
	
RUN mkdir cuvis_tmp && cd cuvis_tmp && \
    wget https://cloud.cubert-gmbh.de/s/qpxkyWkycrmBK9m/download -q && \
    unzip -q download && \
    ls -la . && \
    ls -la  ./Cuvis\ ${CUVIS_MINOR_V} && \
    ls -la  ./Cuvis\ ${CUVIS_MINOR_V}/Cuvis\ ${CUVIS_VERSION} && \
    ls -la  ./Cuvis\ ${CUVIS_MINOR_V}/Cuvis\ ${CUVIS_VERSION}/Ubuntu\ ${UBUNTU_VERSION}-amd64-nocuda && \
    cd  ./Cuvis\ ${CUVIS_MINOR_V}/Cuvis\ ${CUVIS_VERSION}/Ubuntu\ ${UBUNTU_VERSION}-amd64-nocuda && \
    ls -la . && \
    apt-get install ./cuviscommon_${UBUNTU_VERSION}-1.deb -y && \
    apt-get install ./libcuvis_${UBUNTU_VERSION}-1.deb -y && \
    cd / && \
    rm -r /cuvis_tmp
	
ENV CUVIS=/lib/cuvis
