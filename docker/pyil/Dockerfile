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

ARG PYTHON_VERSION=3.12
ARG NUMPY_VERSION=1.26.0

ENV CUVIS=/lib/cuvis

RUN apt-get install curl gcc g++ make swig -y && \
    apt-get install python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev python3-pip -y


WORKDIR /tmp

# download and install cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.25.1/cmake-3.25.1-Linux-x86_64.sh -q -O cmake_install.sh && \
	chmod u+x ./cmake_install.sh && \
	mkdir /opt/cmake-3.25.1 && \
	./cmake_install.sh --skip-license --prefix=/opt/cmake-3.25.1 && \
	ln -s /opt/cmake-3.25.1/bin/* /usr/local/bin

WORKDIR /app

RUN git clone https://github.com/cubert-hyperspectral/cuvis.pyil.git && \
    cd cuvis.pyil && \
	git submodule update --init --recursive
	
# build pyil wrapper
RUN mkdir _pyil && \
	python${PYTHON_VERSION} -m venv .venv && \
	.venv/bin/pip install numpy==${NUMPY_VERSION} && \
	cmake  -DCMAKE_BUILD_TYPE=Release -B ./_pyil -DPython_ROOT_DIR=./.venv -S ./cuvis.pyil && \
	cmake --build "_pyil" --target cuvis_pyil --config Release && \
	cp _pyil/_cuvis_pyil.so ./cuvis.pyil/cuvis_il && \
	cp _pyil/cuvis_il.py ./cuvis.pyil/cuvis_il
	
RUN cd cuvis.pyil && \
	python${PYTHON_VERSION} -m pip install .  --break-system-packages

# Check if bindings can be loaded	
RUN OUTPUT=$(python${PYTHON_VERSION} -c "from cuvis_il import cuvis_il; print(cuvis_il.cuvis_version_swig())") && \
	echo "$OUTPUT" | grep -q "CUBERT SDK" || exit 1
