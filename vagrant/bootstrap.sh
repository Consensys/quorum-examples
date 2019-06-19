#!/bin/bash
set -eu -o pipefail

# install build deps
add-apt-repository ppa:ethereum/ethereum
apt-get update
apt-get install -y build-essential unzip libdb-dev libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev solc sysvbanner wrk software-properties-common default-jdk maven

# install constellation
CVER="0.3.2"
CREL="constellation-$CVER-ubuntu1604"
wget -q https://github.com/jpmorganchase/constellation/releases/download/v$CVER/$CREL.tar.xz
tar xfJ ${CREL}.tar.xz
cp ${CREL}/constellation-node /usr/local/bin && chmod 0755 /usr/local/bin/constellation-node
rm -rf ${CREL}

# install tessera
mkdir -p /home/vagrant/tessera
wget -O /home/vagrant/tessera/tessera.jar -q https://oss.sonatype.org/content/groups/public/com/jpmorgan/quorum/tessera-app/0.9.2/tessera-app-0.9.2-app.jar
wget -O /home/vagrant/tessera/enclave.jar -q https://oss.sonatype.org/content/groups/public/com/jpmorgan/quorum/enclave-jaxrs/0.9.2/enclave-jaxrs-0.9.2-server.jar
echo "TESSERA_JAR=/home/vagrant/tessera/tessera.jar" >> /home/vagrant/.profile
echo "ENCLAVE_JAR=/home/vagrant/tessera/enclave.jar" >> /home/vagrant/.profile

# install golang
GOREL=go1.9.3.linux-amd64.tar.gz
wget -q https://dl.google.com/go/${GOREL}
tar xfz ${GOREL}
mv go /usr/local/go
rm -f ${GOREL}
PATH=$PATH:/usr/local/go/bin
echo 'PATH=$PATH:/usr/local/go/bin' >> /home/vagrant/.bashrc

# make/install quorum
git clone https://github.com/jpmorganchase/quorum.git
pushd quorum >/dev/null
git checkout tags/v2.2.4
make all
cp build/bin/geth /usr/local/bin
cp build/bin/bootnode /usr/local/bin
popd >/dev/null

# install Porosity
wget -q https://github.com/jpmorganchase/quorum/releases/download/v1.2.0/porosity
mv porosity /usr/local/bin && chmod 0755 /usr/local/bin/porosity

# copy examples
cp -r /vagrant/examples /home/vagrant/quorum-examples
chown -R vagrant:vagrant /home/vagrant/quorum /home/vagrant/quorum-examples

# done!
banner "Quorum"
echo
echo 'The Quorum vagrant instance has been provisioned. Examples are available in ~/quorum-examples inside the instance.'
echo "Use 'vagrant ssh' to open a terminal, 'vagrant suspend' to stop the instance, and 'vagrant destroy' to remove it."
