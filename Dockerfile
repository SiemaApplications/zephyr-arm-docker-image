FROM ubuntu:20.04

ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND noninteractive

RUN dpkg --add-architecture i386 && \
	apt-get -y update && \
	apt-get -y upgrade && \
	apt-get install --no-install-recommends -y \
	wget \
	autoconf \
	automake \
	build-essential \
	ccache \
	device-tree-compiler \
	dfu-util \
	file \
	g++ \
	gcc \
	gcc-multilib \
	g++-multilib \
	gcovr \
	git \
	git-core \
	gperf \
	iproute2 \
        jq \
	lcov \
	libglib2.0-dev \
	libpcap-dev \
	libsdl2-dev:i386 \
	libtool \
	locales \
	make \
	cmake \
	net-tools \
	ninja-build \
	openbox \
	pkg-config \
	python3-dev \
	python3-pip \
	python3-ply \
	python3-setuptools \
	python-is-python3 \
	python-xdg \
	qemu \
	socat \
	sudo \
	xxd \
	xz-utils && \
	wget --progress=dot:mega https://apt.kitware.com/kitware-archive.sh && \
	bash kitware-archive.sh && \
	rm kitware-archive.sh && \
	apt-get install --no-install-recommends -y cmake && \
	rm -rf /var/lib/apt/lists/*


RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ARG ZEPHYR_VERSION=v3.0.0
# mcuboot version retrieved from zephyr's manifest at ZEPHYR_VERSION.
ARG MCUBOOT_VERSION=89936c338e46f43cb177a8b928cd80b90f3ace8f

# Install required python package minus imgtool, for which we want to use the one delivered with mcuboot's project
RUN pip3 install --no-cache-dir wheel &&\
	pip3 install --no-cache-dir -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/${ZEPHYR_VERSION}/scripts/requirements.txt && \
	pip3 install --no-cache-dir -r https://raw.githubusercontent.com/zephyrproject-rtos/mcuboot/${MCUBOOT_VERSION}/scripts/requirements.txt && \
	pip3 install --no-cache-dir west && \
        pip3 install --no-cache-dir yq && \
        pip3 uninstall --no-cache-dir -y imgtool && \
	pip3 install --no-cache-dir sh

RUN mkdir -p /opt/

ARG ZSDK_VERSION=0.13.2
ARG ARCH=arm
ARG TOOLCHAIN_SCRIPT=zephyr-toolchain-${ARCH}-${ZSDK_VERSION}-linux-x86_64-setup.run
RUN wget -q --show-progress --progress=bar:force:noscroll --no-check-certificate https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/${TOOLCHAIN_SCRIPT} && \
	sh "${TOOLCHAIN_SCRIPT}" --quiet -- -d /opt/zephyr-sdk-${ZSDK_VERSION} && \
	rm "${TOOLCHAIN_SCRIPT}"

ARG GH_VERSION=2.11.3
ARG GH_DEB=gh_${GH_VERSION}_linux_amd64.deb
ARG GH_URL=https://github.com/cli/cli/releases/download/v${GH_VERSION}/${GH_DEB}
RUN wget -q --show-progress --progress=bar:force:noscroll --no-check-certificate ${GH_URL} && \
	dpkg -i ${GH_DEB} && \
	rm ${GH_DEB}

RUN groupadd -g $GID -o user \
	&& useradd --no-log-init --uid $UID --create-home --gid user --groups plugdev user \
	&& echo 'user ALL = NOPASSWD: ALL' > /etc/sudoers.d/user \
	&& chmod 0440 /etc/sudoers.d/user \
	&& chown -R user:user /home/user

VOLUME /src
WORKDIR /src
