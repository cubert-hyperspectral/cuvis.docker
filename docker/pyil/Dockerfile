ARG UBUNTU_VERSION=24.04
ARG CUVIS_VERSION=3.5.3

FROM cubertgmbh/cuvis_base:${CUVIS_VERSION}-ubuntu${UBUNTU_VERSION}
LABEL maintainer="birkholz@cubert-gmbh.de"

ARG UBUNTU_VERSION
ARG CUVIS_VERSION

### Avoid installer user interaction
ENV DEBIAN_FRONTEND=noninteractive 
	
ARG PYTHON_VERSION=3.12
ARG NUMPY_VERSION=1.26.0

RUN apt-get update && \ 
	apt-get install curl gcc g++ make swig -y && \
    apt-get install python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev python3-pip -y && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Remove PEP 668 warning once
RUN if grep -q 'VERSION_ID="24.04"' /etc/os-release; then \
		rm -rf /usr/lib/python${PYTHON_VERSION}/EXTERNALLY-MANAGED; \
	fi

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
	if grep -q 'VERSION_ID="22.04"' /etc/os-release; then \
		python${PYTHON_VERSION} -m pip install --upgrade pip setuptools wheel build packaging; \
	fi && \
	python${PYTHON_VERSION} -m pip install .

	
# Check if bindings can be loaded	
RUN OUTPUT=$(python${PYTHON_VERSION} -c "from cuvis_il import cuvis_il; print(cuvis_il.cuvis_version_swig())") && \
	echo "$OUTPUT" | grep -q "CUBERT SDK" || exit 1
