# ZSL on Quorum Example

This repository contains a modified 7nodes example to demonstrate [ZSL on Quroum](https://github.com/jpmorganchase/zsl-q/blob/master/README.md)

The following changes have been made:

* ZSL precompiles added to `genesis.json` between address 0x8801 - 0x8804
* Node 2 is unlocked in `raft-start.sh`
* Symbolic links added for accessing ZSL parameters (proving and verification keys) when the example is run inside Vagrant.  These symbolic links can be replaced with actual parameter files if running from the local host machine, and not inside Vagrant.
* New file `tracker.js` contains note tracking and other helper functions.

There are examples of using ZSL on 7nodes documented in [ZSL on Quorum](https://github.com/jpmorganchase/zsl-q/tree/master/README.md)

Original README follows.

# Quorum Examples

This repository contains setup examples for Quorum.

Current examples include:
* [7nodes](https://github.com/jpmorganchase/quorum-examples/tree/master/examples/7nodes): Starts up a fully-functioning Quorum environment consisting of 7 independent nodes with a mix of block makers, voters, and unprivileged nodes. From this example one can test consensus, privacy, and all the expected functionality of an Ethereum platform.
* [permissions](https://github.com/jpmorganchase/quorum-examples/tree/master/examples/permissions): Focuses on how to add, remove, and update the list of nodes permitted to participate in the network.
* [5nodesRTGS](https://github.com/bacen/quorum-examples/tree/master/examples/5nodesRTGS): [__Note__: This links to an external repo which you will need to clone, thanks to @rsarres for this contribution!] Starts up a set of 5 nodes that simulates a Real-time Gross Setlement environment with 3 banks, one regulator (typically a central bank) and an observer that cannot access the private data. 

The easiest way to get started with running the examples is to use the vagrant environment (see below).

**Important note**: Any account/encryption keys contained in this repository are for
demonstration and testing purposes only. Before running a real environment, you should
generate new ones using Geth's `account` tool and `constellation-enclave-keygen`.

## Vagrant Usage

This is a complete Vagrant environment containing Quorum, Constellation, and the
Quorum examples.

### Requirements

  1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
  1. Install [Vagrant](https://www.vagrantup.com/downloads.html)

(If you are behind a proxy server, please see https://github.com/jpmorganchase/quorum/issues/23)

### Running

```sh
git clone https://github.com/jpmorganchase/quorum-examples
cd quorum-examples
vagrant up
# (should take 5 or so minutes)
vagrant ssh
# Once in the VM environment:
cd quorum-examples 
#then simply follow the instructions for the demo you'd like to run.
```

(*macOS note*: If you get an error saying that the ubuntu/xenial64 image doesn't
exist, please run `sudo rm -r /opt/vagrant/embedded/bin/curl`. This is usually due to
issues with the version of curl bundled with Vagrant.)



To shut down the Vagrant instance, run `vagrant suspend`. To delete it, run
`vagrant destroy`. To start from scratch, run `vagrant up` after destroying the
instance.

