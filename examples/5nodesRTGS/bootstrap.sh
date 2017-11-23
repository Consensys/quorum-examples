#!/bin/bash
set -eu -o pipefail

# install build deps
add-apt-repository ppa:ethereum/ethereum
apt-get update
apt-get install -y build-essential unzip libdb-dev libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev solc sysvbanner wrk

# install constellation
CREL=constellation-0.2.0-ubuntu1604
wget -q https://github.com/jpmorganchase/constellation/releases/download/v0.2.0/$CREL.tar.xz
tar xfJ $CREL.tar.xz
cp $CREL/constellation-node /usr/local/bin && chmod 0755 /usr/local/bin/constellation-node
rm -rf $CREL

# install golang
add-apt-repository ppa:gophers/archive
apt update
apt-get install golang-1.9-go
PATH=$PATH:/usr/lib/go-1.9/bin

# make/install quorum
git clone https://github.com/jpmorganchase/quorum.git
pushd quorum >/dev/null
git checkout tags/v2.0.0
make all
cp build/bin/geth /usr/local/bin
cp build/bin/bootnode /usr/local/bin
popd >/dev/null


# done!
banner "Quorum"
echo
echo 'Quorum has been installed.'
