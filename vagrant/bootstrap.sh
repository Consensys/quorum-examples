#!/bin/bash
set -eu -o pipefail

# nodejs source for apt
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

apt-get update
packages=(
    parallel       # utility
    unzip          # tessera startup script dependency
    default-jdk    # tessera runtime dependency
    libleveldb-dev # constellation dependency
    libsodium-dev  # constellation dependency
    nodejs         # cakeshop dependency
)
apt-get install -y ${packages[@]}

CVER="0.3.2"
CREL="constellation-$CVER-ubuntu1604"
CONSTELLATION_OUTPUT_FILE="constellation.tar.xz"
POROSITY_OUTPUT_FILE="/usr/local/bin/porosity"

TESSERA_HOME=/home/vagrant/tessera
mkdir -p ${TESSERA_HOME}
TESSERA_VERSION="0.10.3"
TESSERA_OUTPUT_FILE="${TESSERA_HOME}/tessera.jar"
TESSERA_ENCLAVE_OUTPUT_FILE="${TESSERA_HOME}/enclave.jar"

CAKESHOP_HOME=/home/vagrant/cakeshop
mkdir -p ${CAKESHOP_HOME}
CAKESHOP_VERSION="0.11.0-RC2"
CAKESHOP_OUTPUT_FILE="${CAKESHOP_HOME}/cakeshop.war"

QUORUM_VERSION="2.4.0"
QUORUM_OUTPUT_FILE="geth.tar.gz"

# download binaries in parallel
echo "Downloading binaries ..."
parallel --link wget -q -O ::: \
    ${CONSTELLATION_OUTPUT_FILE} \
    ${TESSERA_OUTPUT_FILE} \
    ${TESSERA_ENCLAVE_OUTPUT_FILE} \
    ${QUORUM_OUTPUT_FILE} \
    ${POROSITY_OUTPUT_FILE} \
    ${CAKESHOP_OUTPUT_FILE} \
    ::: \
    https://github.com/jpmorganchase/constellation/releases/download/v$CVER/$CREL.tar.xz \
    https://oss.sonatype.org/content/groups/public/com/jpmorgan/quorum/tessera-app/${TESSERA_VERSION}/tessera-app-${TESSERA_VERSION}-app.jar \
    https://oss.sonatype.org/content/groups/public/com/jpmorgan/quorum/enclave-jaxrs/${TESSERA_VERSION}/enclave-jaxrs-${TESSERA_VERSION}-server.jar \
    https://dl.bintray.com/quorumengineering/quorum/v${QUORUM_VERSION}/geth_v${QUORUM_VERSION}_linux_amd64.tar.gz \
    https://github.com/jpmorganchase/quorum/releases/download/v1.2.0/porosity \
    https://github.com/jpmorganchase/cakeshop/releases/download/v${CAKESHOP_VERSION}/cakeshop-${CAKESHOP_VERSION}.war

# install constellation
echo "Installing Constellation ${CVER}"
tar xfJ ${CONSTELLATION_OUTPUT_FILE}
cp ${CREL}/constellation-node /usr/local/bin && chmod 0755 /usr/local/bin/constellation-node
rm -rf ${CREL}
rm -f ${CONSTELLATION_OUTPUT_FILE}

# install tessera
echo "Installing Tessera ${TESSERA_VERSION}"
echo "TESSERA_JAR=${TESSERA_OUTPUT_FILE}" >> /home/vagrant/.profile
echo "ENCLAVE_JAR=${TESSERA_ENCLAVE_OUTPUT_FILE}" >> /home/vagrant/.profile

# install Quorum
echo "Installing Quorum ${QUORUM_VERSION}"
tar xfz ${QUORUM_OUTPUT_FILE} -C /usr/local/bin
rm -f ${QUORUM_OUTPUT_FILE}

# install Porosity
echo "Installing Porosity"
chmod 0755 ${POROSITY_OUTPUT_FILE}

# install cakeshop
echo "Installing Cakeshop ${CAKESHOP_VERSION}"
echo "CAKESHOP_JAR=${CAKESHOP_OUTPUT_FILE}" >> /home/vagrant/.profile


# copy examples
cp -r /vagrant/examples /home/vagrant/quorum-examples
chown -R vagrant:vagrant /home/vagrant/quorum-examples

# from source script
cp /vagrant/go-source.sh /home/vagrant/go-source.sh
chown vagrant:vagrant /home/vagrant/go-source.sh

# done!
echo "
 ____  _     ____  ____  _     _
/  _ \/ \ /\/  _ \/  __\/ \ /\/ \__/|
| / \|| | ||| / \||  \/|| | ||| |\/||
| \_\|| \_/|| \_/||    /| \_/|| |  ||
\____\\____/\____/\_/\_\\____/\_/  \|
--------                    ---------
        \     Examples     /
         ------------------
"
echo
echo 'The Quorum vagrant instance has been provisioned. Examples are available in ~/quorum-examples inside the instance.'
echo "Use 'vagrant ssh' to open a terminal, 'vagrant suspend' to stop the instance, and 'vagrant destroy' to remove it."
