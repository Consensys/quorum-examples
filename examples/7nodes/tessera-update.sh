#!/bin/bash
# Update Tessera

set -u
set -e

echo "========== Update Tessera =========="
pushd /home/vagrant >/dev/null
pushd tessera >/dev/null
git pull

echo "========== Build Tessera =========="
mvn --batch-mode -DskipTests install

popd >/dev/null
popd >/dev/null
