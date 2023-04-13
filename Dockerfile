FROM debian:bullseye

#Set Manufacturer Address
ENV MANUFACTURER_ADDRESS="http://10.149.170.203:8039"

# install dependencies
RUN apt-get update && \
    apt-get install -y git cmake gcc nano wget netcat iputils-ping && \
    apt-get install -y build-essential python-setuptools clang-format dos2unix ruby build-essential &&\
    apt-get install -y libglib2.0-dev libpcap-dev autoconf libtool libproxy-dev doxygen cmake libssl-dev mercurial

#install libcbor-dev if you get this error "fatal error: cbor.h: No such file or directory"
RUN apt-get install -y libcbor-dev
#install libtss2-dev if you get this error "fatal error: "tss2/tss2_esys.h: No such file or directory"
RUN apt-get install -y libtss2-dev
#install libmbedtls-dev if you get this error  "fatal error: metee.h: No such file or directory" 
RUN apt-get install -y libmbedtls-dev

#install for hawkbit-onboarding
RUN apt-get install -y inotify-tools swupdate

#install openssl and curl
RUN wget https://www.openssl.org/source/openssl-1.1.1s.tar.gz && \
    tar -zxf openssl-1.1.1s.tar.gz && cd openssl-1.1.1s && \
    ./config && \
    make && \
    make test && \
    mv /usr/bin/openssl ~/tmp && \
    make install && \
    ln -s /usr/local/bin/openssl /usr/bin/openssl && \
    wget https://github.com/curl/curl/releases/download/curl-7_86_0/curl-7.86.0.tar.gz && \
    tar -zxf curl-7.86.0.tar.gz && cd curl-7.86.0 && \
    ./configure --with-openssl --enable-versioned-symbols && \
    make -j$(nproc) && \
    make install


#install safestring library
RUN git clone https://github.com/intel/safestringlib.git && \
    export SAFESTRING_ROOT=./safestringlib && \
    cd ${SAFESTRING_ROOT} && \
    mkdir obj && \
    make && \
    export SAFESTRING_ROOT=./safestringlib 

#install Tinycbor library
RUN git clone https://github.com/intel/tinycbor.git --branch v0.5.3 && \
    export TINYCBOR_ROOT=./tinycbor && \
    cd ${TINYCBOR_ROOT} && \
    make && \
    export TINYCBOR_ROOT=./tinycbor 

#install METEE library
RUN git clone https://github.com/intel/metee.git && \
    export METEE_ROOT=./metee && \
    cd ${METEE_ROOT} && \
    cmake . && \
    make -j$(nproc) && \
    make install && \
    export METEE_ROOT=./metee 

# Copy your script into the container 
COPY generate_keys.sh /
COPY hawkbit-onboarding.sh /
# Make the script executable
RUN chmod +x /generate_keys.sh
RUN chmod +x /hawkbit-onboarding.sh

# clone the client sdk repo
RUN git clone https://github.com/Vishwasrao1/client-sdk-fidoiot.git

# Add dummy certificate and a ecdsa384privkey
COPY hb-cert.crt /

#install xxd
RUN apt-get install -y vim-common

#Build linux-client

ENV BUILD="debug"
ENV HTTPPROXY="false"
ENV AES_MODE="gcm"
ENV DA="ecdsa384"
ENV LOG_LEVEL="6"


RUN cd client-sdk-fidoiot && \
    export SAFESTRING_ROOT=/safestringlib && \
    export TINYCBOR_ROOT=/tinycbor && \
    export METEE_ROOT=/metee && \
    #./build.sh && \
    echo " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " && \
    echo "${LOG_LEVEL}":"${DA}":"${BUILD}":"${AES_MODE}" && \
    echo " >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< " && \
    #Remove -DRESUSE=true at the time of production
    cmake -DREUSE=true -DHTTPPROXY=${HTTPPROXY} -DBUILD=${BUILD} -DDA=${DA} -DAES_MODE=${AES_MODE} -DLOG_LEVEL=${LOG_LEVEL} -DOPTIMIZE=1 . && \
    make -j$(nproc) && \
    mkdir -p "/opt/fdo" && \
    install "/client-sdk-fidoiot/build/linux-client" "/opt/fdo" && \
    mkdir -p "/opt/fdo/data" && \
    cp -r "/client-sdk-fidoiot/data/" "/opt/fdo/" && \
    #echo -n "${MANUFACTURER_ADDRESS}" > /opt/fdo/data/manufacturer_addr.bin && \
    # generate data backup
    mkdir -p "/opt/fdo/data_bkp" && \
    cp -r "/opt/fdo/data/" "/opt/fdo/data_bkp"

# Build the linux client first && Manufacture the device && watch for hawkbit.config file && Install the device on site
CMD ["/bin/bash", "-c", "/generate_keys.sh && /hawkbit-onboarding.sh & tail -f /dev/null"]

