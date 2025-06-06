ARG UBUNTU_VERSION=24.04
ARG CUVIS_VERSION=3.3.3

FROM cubertgmbh/cuvis_pyil:${CUVIS_VERSION}-ubuntu${UBUNTU_VERSION} as pyil_base
LABEL maintainer="birkholz@cubert-gmbh.de"

ARG UBUNTU_VERSION
ARG CUVIS_VERSION

FROM ubuntu:${UBUNTU_VERSION}

ARG UBUNTU_VERSION
ARG CUVIS_VERSION
ARG CUVIS_MINOR_V=3.3

# Get access to Cuvis Python Interface Layer
COPY --from=pyil_base /app/cuvis.pyil /app/cuvis.pyil

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

ARG PYTHON_VERSION=3.12
ARG NUMPY_VERSION=1.26.0

RUN apt-get install curl python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev python3-pip -y

WORKDIR /app

RUN cd cuvis.pyil && \
	python${PYTHON_VERSION} -m pip install . --break-system-packages

RUN git clone https://github.com/cubert-hyperspectral/cuvis.python.git && \
	cd cuvis.python && \
	python${PYTHON_VERSION} -m pip install . --break-system-packages	
	
# Check if sdk wrapper can be loaded	
RUN OUTPUT=$(python${PYTHON_VERSION} -c "import cuvis; print(cuvis.version())") && \
	echo "$OUTPUT" | grep -q "CUBERT SDK" || exit 1
