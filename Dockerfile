FROM ubuntu:xenial

WORKDIR /tmp

# install build deps
RUN apt-get update -y
RUN apt-get install -y software-properties-common unzip && \
    add-apt-repository -y ppa:ethereum/ethereum && \
    apt-get update -y && \
    apt-get install -y build-essential unzip libdb-dev libsodium-dev zlib1g-dev libtinfo-dev solc sysvbanner wrk wget git

# install constellation
RUN wget https://github.com/jpmorganchase/constellation/releases/download/v0.0.1-alpha/ubuntu1604.zip
RUN unzip ubuntu1604.zip && \
    cp ubuntu1604/constellation-node /usr/local/bin && chmod 0755 /usr/local/bin/constellation-node && \
    cp ubuntu1604/constellation-enclave-keygen /usr/local/bin && chmod 0755 /usr/local/bin/constellation-enclave-keygen && \
    rm -rf ubuntu1604.zip ubuntu1604

# install golang
ENV GOREL=go1.7.3.linux-amd64.tar.gz
RUN wget -q https://storage.googleapis.com/golang/$GOREL
RUN tar xfz $GOREL && \
    mv go /usr/local/go && \
    rm -f $GOREL && \
    PATH=$PATH:/usr/local/go/bin && \
    echo 'PATH=$PATH:/usr/local/go/bin' >> /root/.bashrc

WORKDIR /root

# make/install quorum
RUN git clone https://github.com/jpmorganchase/quorum.git
RUN . /root/.bashrc && \
    cd quorum && \
    git checkout tags/v1.1.0 && \
    make all && \
    cp build/bin/geth /usr/local/bin && \
    cp build/bin/bootnode /usr/local/bin && \
    cd ..

# expose a directory for the examples
RUN mkdir -p /quorum-examples
VOLUME /quorum-examples
WORKDIR /quorum-examples/examples/7nodes/
