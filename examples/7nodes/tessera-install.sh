#!/bin/bash
# Install Tessera
# This is a separate script instead of in bootstrap.sh,
# as we need to enter our user details for access to the Tessera github repo.
set -u
set -e

echo "========== Install build dependencies =========="
sudo apt-get install -y default-jdk maven

echo "========== Install Tessera =========="
pushd /home/vagrant >/dev/null
git clone https://github.com/QuorumEngineering/tessera.git
pushd tessera >/dev/null
git checkout master
#git pull

echo "========== Build Tessera =========="
mvn --batch-mode -DskipTests install

popd >/dev/null
popd >/dev/null
