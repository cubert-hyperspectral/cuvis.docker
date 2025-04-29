ARG UBUNTU_VERSION=20.04
ARG CUVIS_VERSION=3.3.0
ARG CUVIS_MINOR_V=3.3

LABEL maintainer="birkholz@cubert-gmbh.de"

FROM cubertgmbh:${CUVIS_VERSION}-ubuntu${UBUNTU_VERSION} as sdk_base

ARG PYTHON_VERSION=3.12
FROM ubuntu:${UBUNTU_VERSION}

# Get access to Cuvis SDK
COPY --from=sdk_base /lib/cuvis /lib/cuvis
COPY --from=sdk_base /usr/include/cuvis.h /usr/include/cuvis.https
COPY --from=sdk_base /etc/ld.so.conf.d/libcuvis.conf /etc/ld.so.conf.d/libcuvis.conf
COPY --from=sdk_base /etc/cuvis /etc/cuvis
COPY --from=sdk_base /var/log/cuvis /var/log/cuvis
COPY --from=sdk_base /usr/share/cuvis /usr/share/cuvis

ENV CUVIS=/lib/cuvis

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install git -y && \
    apt-get install git python3 python3-venv -y && \
	curl -sS https://bootstrap.pypa.io/get-pip.py | python3
	
