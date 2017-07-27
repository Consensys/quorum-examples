#!/bin/bash
set -eu -o pipefail

# Install build deps
add-apt-repository ppa:ethereum/ethereum
apt-get update
apt-get install -y build-essential unzip libdb-dev libsodium-dev zlib1g-dev libtinfo-dev solc sysvbanner wrk

# Install Constellation
cname="constellation-0.1.0-ubuntu1604"
wget -q "https://github.com/jpmorganchase/constellation/releases/download/v0.1.0/$cname.tar.xz"
tar xfJ "$cname.tar.xz"
cp "$cname/constellation-node" /usr/local/bin && chmod 0755 /usr/local/bin/constellation-node
rm -rf "$cname.tar.xz" "$cname"

# Install Go
GOREL=go1.7.3.linux-amd64.tar.gz
wget -q https://storage.googleapis.com/golang/$GOREL
tar xfz $GOREL
mv go /usr/local/go
rm -f $GOREL
PATH=$PATH:/usr/local/go/bin
echo 'PATH=$PATH:/usr/local/go/bin' >> /home/ubuntu/.bashrc

# Make/install Quorum
git clone https://github.com/jpmorganchase/quorum.git
pushd quorum >/dev/null
git checkout tags/v1.1.1
make all
cp build/bin/geth /usr/local/bin
cp build/bin/bootnode /usr/local/bin
popd >/dev/null

# Copy examples
cp -r /vagrant/examples /home/ubuntu/quorum-examples
chown -R ubuntu:ubuntu /home/ubuntu/quorum /home/ubuntu/quorum-examples

# Done!
banner "Quorum"
echo
echo 'The Quorum vagrant instance has been provisioned. Examples are available in ~/quorum-examples inside the instance.'
echo "Use 'vagrant ssh' to open a terminal, 'vagrant suspend' to stop the instance, and 'vagrant destroy' to remove it."
