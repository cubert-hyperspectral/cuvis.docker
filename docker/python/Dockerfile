ARG UBUNTU_VERSION=24.04
ARG CUVIS_VERSION=3.5.3
ARG TAG_SUFFIX=""

FROM cubertgmbh/cuvis_pyil:${CUVIS_VERSION}-ubuntu${UBUNTU_VERSION}${TAG_SUFFIX} AS pyil_base
LABEL maintainer="birkholz@cubert-gmbh.de"

ARG UBUNTU_VERSION
ARG CUVIS_VERSION
ARG TAG_SUFFIX=""

FROM cubertgmbh/cuvis_base:${CUVIS_VERSION}-ubuntu${UBUNTU_VERSION}${TAG_SUFFIX}

SHELL ["/bin/bash", "-lc"]
ARG UBUNTU_VERSION
ARG CUVIS_VERSION

# Get access to Cuvis Python Interface Layer
COPY --from=pyil_base /app/cuvis.pyil /app/cuvis.pyil

### Avoid installer user interaction
ENV DEBIAN_FRONTEND=noninteractive 

ARG PYTHON_VERSION=3.12
ARG NUMPY_VERSION=1.26.0

RUN apt-get update && \
	apt-get install curl python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev python3-pip -y && \
	apt-get clean && rm -rf /var/lib/apt/lists/*

# Remove PEP 668 warning once
RUN if grep -q 'VERSION_ID="24.04"' /etc/os-release; then \
		rm -rf /usr/lib/python${PYTHON_VERSION}/EXTERNALLY-MANAGED; \
	fi

WORKDIR /app

RUN cd cuvis.pyil && \
	python${PYTHON_VERSION} -m pip install .

RUN git clone https://github.com/cubert-hyperspectral/cuvis.python.git && \
	cd cuvis.python && \
	if grep -q 'VERSION_ID="22.04"' /etc/os-release; then \
		python${PYTHON_VERSION} -m pip install --upgrade pip setuptools wheel build packaging; \
	fi && \
	python${PYTHON_VERSION} -m pip install .

# Check if sdk wrapper can be loaded	
RUN OUTPUT=$(python${PYTHON_VERSION} -c "import cuvis; print(cuvis.version())") && \
	echo "$OUTPUT" | grep -q "CUBERT SDK" || exit 1
