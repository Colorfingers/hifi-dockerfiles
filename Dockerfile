FROM ubuntu:18.04 as build

ENV PREFIX="/usr/local"
ENV BIN_DIR="${PREFIX}/bin"
ENV SRC_DIR="${PREFIX}/src"
ENV QT_VERSION=5.10.1
ENV QT_INSTALLER="hifiqt${QT_VERSION}_${QT_VERSION}_amd64.deb"
ENV QT_URL="http://debian.highfidelity.com/pool/h/hi/${QT_INSTALLER}"
ENV QT_PREFIX="/usr/local/Qt${QT_VERSION}/${QT_VERSION}/gcc_64"
ENV QT_CMAKE_PREFIX_PATH="${QT_PREFIX}/lib/cmake"
ENV PATH="${QT_PREFIX}/bin:${BIN_DIR}:${PATH}"
ENV HIFI_SRC_ROOT=${SRC_DIR}/hifi
ENV GIT_TAG=v0.76.0

# Update apt's package definitions
RUN apt-get update

# Install High Fidelity's build of Qt.
RUN apt-get install -y wget && \
    wget ${QT_URL} && dpkg -i ${QT_INSTALLER} && \
    rm ${QT_INSTALLER}

# Install all of High Fidelity's build dependencies.
RUN apt-get -y install \
    build-essential cmake freeglut3-dev git hifiqt${QT_VERSION} libasound2 \
    libasound2-dev libevent-pthreads-2.1-6 libfontconfig1 libjack-dev \
    libjack0 libnspr4 libnss3 libpulse0 libssl-dev libtbb-dev libudev-dev \
    libxcomposite1 libxcursor1 libxi-dev libxmu-dev libxrandr-dev libxslt1.1 \
    libxtst6 python python3 wget zlib1g-dev

# Check out the latest HEAD of High Fidelity.
RUN printenv
RUN mkdir -p ${HIFI_SRC_ROOT} && \
    git clone --branch $GIT_TAG --depth 1 https://github.com/highfidelity/hifi.git $HIFI_SRC_ROOT && \
    mkdir -p $HIFI_SRC_ROOT/build
WORKDIR $HIFI_SRC_ROOT/build

# Build assignment-client
RUN cmake ..
RUN make -j8 assignment-client

WORKDIR $HIFI_SRC_ROOT
COPY patches/*.patch ./
RUN git apply *.patch
RUN git status

# TODO: the number of procs to use should depend on the actual hardware
WORKDIR $HIFI_SRC_ROOT/build
RUN make -j4 assignment-client && \
    strip assignment-client/assignment-client

# Collect all of assignment-client's dependencies
RUN mkdir /tmp/libs && \
    for l in $(ldd assignment-client/assignment-client | awk '$3 != "" { print $3 }'); \
    do cp $l /tmp/libs/; done


FROM ubuntu:18.04

COPY --from=build /tmp/libs/* /usr/local/lib/
COPY --from=build /usr/local/src/hifi/build/assignment-client/assignment-client /usr/local/bin/
RUN ldconfig /usr/local/lib

RUN adduser --disabled-password --gecos '' hifi
USER hifi
WORKDIR /

CMD ["/usr/local/bin/assignment-client"]
ENTRYPOINT ["/usr/local/bin/assignment-client"]
