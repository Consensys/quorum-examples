#!/bin/bash
set -u
set -e

echo "[*] Cleaning up cakeshop data directory"
rm -rf qdata/cakeshop
mkdir -p qdata/cakeshop/local

echo "[*] Copying cakeshop config to data directory"
cp cakeshop/application.properties.template qdata/cakeshop/local/application.properties
cp cakeshop/7nodes.json qdata/cakeshop/local/7nodes.json
