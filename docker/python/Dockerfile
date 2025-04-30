ARG UBUNTU_VERSION=20.04
ARG CUVIS_VERSION=3.3.0

FROM cubertgmbh/cuvis_pyil:${CUVIS_VERSION}-ubuntu${UBUNTU_VERSION} as pyil_base
LABEL maintainer="birkholz@cubert-gmbh.de"

ARG UBUNTU_VERSION
ARG CUVIS_VERSION

FROM ubuntu:${UBUNTU_VERSION}
ARG PYTHON_VERSION=3.12
ARG NUMPY_VERSION=1.22.0
ARG UBUNTU_VERSION
ARG CUVIS_VERSION
ARG CUVIS_MINOR_V=3.3

# Get access to Cuvis Python Interface Layer
COPY --from=pyil_base /app/cuvis.pyil /app/cuvis.pyil

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

ARG PYTHON_VERSION=3.9

RUN apt-get install curl python${PYTHON_VERSION} python${PYTHON_VERSION}-venv -y && \
	curl -sS https://bootstrap.pypa.io/get-pip.py | python${PYTHON_VERSION}

WORKDIR /app

RUN cd cuvis.pyil && \
	python${PYTHON_VERSION} -m pip install .

RUN git clone https://github.com/cubert-hyperspectral/cuvis.python.git && \
	cd cuvis.python && \
	python${PYTHON_VERSION} -m pip install .	