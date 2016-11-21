
# Node Permissioning Example

Node Permissioning is a feature in Quorum that allows only a pre-defined set of nodes (as identified by their remotekey/enodes) to connect to the permissioned network.

This example demonstrates the following:
* Sets up a network with a combination of permissioned and non-permissioned nodes in the cluster.
* Enabling / Disabling the permissions from command line.
* Details of permissioned-nodes.json file.
* Demonstrate that only the nodes that are specified in permissioned-nodes.json can connect to the network.

## Usage

```
./run_nodes.sh GETH_BINARY DATADIR_BASE PERMISSONED_NODES NON_PERMISSIONED_NODES

where:

  GETH_BINARY is the geth command you want to use
  DATADIR_BASE is the folder under which node specific datadir will be created
  PERMISSONED_NODES is the number of Permissioned Nodes to start.
  NON_PERMISSIONED_NODES is number of non permissioned nodes to start.

```

For example:
```
$ ./run_nodes.sh /usr/local/bin/geth /tmp/chaindata 5 3
```
will start 5 permissioned nodes with node numbers from 1-5 and 3
non-permissioned nodes from 6-8.

or:

```
./run_nodes.sh default
```

to use default settings.

Sample output (condensed for clarity):

```
$ ./run_nodes.sh default
*
Initializing Environment
*** Starting Permissioned Nodes ****
Running Permissioned Nodes
Started Permissioned node 1 with enode://8475a01f22a1f48116dc1f0d22ecaaaf77e5
Started Permissioned node 2 with enode://b5660501f496e60e59ded734a889c97b7da9
Started Permissioned node 3 with enode://54bd7ff4bd971fb80493cf47064553959176
Started Permissioned node 4 with enode://24a62b436686d550e92c84cc314565012d71
Started Permissioned node 5 with enode://246740a1ccb5d6f419c1f86e002332a58e246

*** All permissioned nodes Started. Please check the output for any errors ****

*** Starting UnPermissioned Nodes ****

Started Unpermissioned node 6 with enode://4c80d699a358a915635ae4cc3cedeacb92d
Started Unpermissioned node 7 with enode://005be0525b47039923bb4ed7ab53f14a53b4
Started Unpermissioned node 8 with enode://375d1b75c230ff7434a4b2534fb1eb6482a6

*** All Unpermissoned nodes Started. Please check the output for any errors ****

**** Update permissions config on each node ***
copying permissioned-nodes.json to pdata/1
copying permissioned-nodes.json to pdata/2
copying permissioned-nodes.json to pdata/3
copying permissioned-nodes.json to pdata/4
copying permissioned-nodes.json to pdata/5
```

* ### Verify only permissioned nodes are connected to the network.

* Attach to the individual nodes via
	`geth attach ipc:/path/to/geth.ipc` and use `admin.peers` to check the connected nodes.

```
geth attach ipc:./pdata/1/geth.ipc
instance: Geth/node_1/v1.5.0-unstable-42adaae1/darwin/go1.6.2
> admin.peers
[{
    caps: ["eth/62", "eth/63"],
    id: "246740a1ccb5d6f419c1f86e002332a58e246f39f411d61e51b763a3f226a082fba275652c9ce01e5d5f81a7ba2850bea4611247d745e278f3a558e6345ee75a",
    name: "Geth/node_5/v1.5.0-unstable-42adaae1/darwin/go1.6.2",
    network: {
      localAddress: "127.0.0.1:59706",
      remoteAddress: "127.0.0.1:30305"
    },
    protocols: {
      eth: {
        difficulty: 17179869184,
        head: "0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3",
        version: 63
      }
    }
}, {
    caps: ["eth/62", "eth/63"],
    id: "54bd7ff4bd971fb80493cf470645539591767d492a8229dcb8adc10129fc4c6bfd8f6044c75e806c4c9fdcec4e9b956d00d495ce273e9ae6c7347b90a9f5356b",
    name: "Geth/node_3/v1.5.0-unstable-42adaae1/darwin/go1.6.2",
    network: {
      localAddress: "127.0.0.1:30301",
      remoteAddress: "127.0.0.1:56980"
    },
    protocols: {
      eth: {
        difficulty: 17179869184,
        head: "0xd4e56740f876aef8c010b86a40d5f56745a118d0906a34e69aec8c0db1cb8fa3",
        version: 63
      }
    }
}]
```


* You can also inspect the log files under `logs/node*.log` for further diagnostics messages around incoming / outgoing connection requests. Grep for `ALLOWED-BY` or `DENIED-BY`. Please be sure to enable verobsity for p2p module.

* #### Permissioning configuration

	Permissioning is granted based on the remote key of the geth node. The remote keys are specified in the permissioned-nodes.json and is placed under individual nodes <datadir>.

	The below sample permissioned-nodes.json provides a list of nodes permissioned to join the network ( node ids truncated for clarity)

```
[
   "enode://8475a01f22a1f48116dc1f0d22ecaaaf77e[::]:30301",
   "enode://b5660501f496e60e59ded734a889c97b7da[::]:30302",
   "enode://54bd7ff4bd971fb80493cf4706455395917[::]:30303"
]
```

* #### Enabling/Disabling permissions

	An individual node can enable/disable permissioning by passing the `-permissioned` command line flag. If enabled, then only the nodes that are in the `<datadir>/permissioned-nodes.json` can connect to it. Further, these are the only nodes that this node can make outbound connections to as well.

```
MISCELLANEOUS OPTIONS:
--permissioned          If enabled, the node will allow only a defined list of nodes to connect
```
