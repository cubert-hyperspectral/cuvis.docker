FROM ubuntu:22.04

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install git wget unzip libtool autoconf sed nano -y && \
    apt-get install python3 python3-pip python3-venv python-is-python3 -y

RUN mkdir cuvis_tmp && cd cuvis_tmp && \
    wget https://cloud.cubert-gmbh.de/s/qpxkyWkycrmBK9m/download -q && \
    unzip -q download && \
    ls -la . && \
    ls -la  ./Cuvis\ 3.3 && \
    ls -la  ./Cuvis\ 3.3/Cuvis\ 3.3.0 && \
    ls -la  ./Cuvis\ 3.3/Cuvis\ 3.3.0/Ubuntu\ 22.04-amd64-nocuda && \
    cd  ./Cuvis\ 3.3/Cuvis\ 3.3.0/Ubuntu\ 22.04-amd64-nocuda && \
    ls -la . && \
    apt-get install ./cuviscommon_3.3.0-1.deb -y && \
    apt-get install ./libcuvis_3.3.0-1.deb -y && \
    cd / && \
    rm -r /cuvis_tmp

WORKDIR /data

ENV CUVIS=/lib/cuvis

ENTRYPOINT ["/bin/bash", "-c", "/data/start-script.sh"]
