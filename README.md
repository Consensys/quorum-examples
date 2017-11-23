# Quorum Examples

This repository contains setup examples for Quorum.

Current BACEN example is:
* [5nodesRTGS](https://github.com/bacen/quorum-examples/tree/master/examples/5nodesRTGS): Starts up a set of 5 nodes that simulates a Real-time Gross Setlement environment with 3 banks, one regulator (typically a central bank) and an observer that cannot access the private data. 

The easiest way to get started with running the examples is to use a clean Ubuntu 16.04 environment (see README at 5nodesRTGS directory).

**Important note**: Any account/encryption keys contained in this repository are for
demonstration and testing purposes only. Before running a real environment, you should
generate new ones using Geth's `account` tool and `constellation-enclave-keygen`.

## Usage
```sh
git clone https://github.com/bacen/quorum-examples
cd quorum-examples
cd examples
cd 5nodesRTGS
./bootstrap.sh
# (run as root, should take some user confirmations, requires internet connection)
```
