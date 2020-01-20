# Quorum Examples

This repository contains setup examples for Quorum Platform.

Current examples include:
* [7nodes](examples/7nodes): Starts up a fully-functioning Quorum environment consisting of 7 independent nodes. From this example one can test consensus, privacy, and all the expected functionality of an Ethereum platform.

Additional examples exist highlighting and showcasing the functionality offered by the Quorum platform.  An up-to-date list can be found in the [Quorum Documentation](https://docs.goquorum.com/en/latest/Getting%20Started/Quorum-Examples/) site.

## Installation
Clone the [`quorum-examples`](https://github.com/jpmorganchase/quorum-examples.git) repo. 

```bash
git clone https://github.com/jpmorganchase/quorum-examples.git
```

**Important note**: Any account/encryption keys used in the quorum-examples repo are for demonstration and testing purposes only. Before running a real environment, new keys should be generated using Geth's `account` tool, Tessera's `-keygen` option, and Constellation's `--generate-keys` option


## Prepare your environment

A 7 node Quorum network must be running before the example can be run.  The [`quorum-examples`](https://github.com/jpmorganchase/quorum-examples.git) repo provides the means to create a pre-configured sample network in minutes.  

There are 3 ways to start the sample network, each method is detailed below:

1. By running a pre-configured Vagrant virtual-machine environment which comes complete with Quorum, Constellation, Tessera and the 7nodes example already installed.  Bash scripts provided in the examples are used to create the sample network: [Running with Vagrant](#running-with-vagrant)
1. By running [`docker-compose`](https://docs.docker.com/compose/) against a [preconfigured `compose` file](https://github.com/jpmorganchase/quorum-examples/blob/master/docker-compose.yml) to create the sample network: [Running with Docker](#running-with-docker)
1. By installing Quorum and Tessera/Constellation locally and using bash scripts provided in the examples to create the sample network: [Running locally](#running-locally)

Your environment must be prepared differently depending on the method being used to run the example.


### Running with Vagrant
1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. Install [Vagrant](https://www.vagrantup.com/downloads.html)
3. Download and start the Vagrant instance (note: running `vagrant up` takes approx 5 mins):

    ```sh
    git clone https://github.com/jpmorganchase/quorum-examples
    cd quorum-examples
    vagrant up
    vagrant ssh
    ```

4. To shutdown the Vagrant instance, run `vagrant suspend`. To delete it, run
   `vagrant destroy`. To start from scratch, run `vagrant up` after destroying the
   instance.


#### Troubleshooting Vagrant
* If you are behind a proxy server, please see https://github.com/jpmorganchase/quorum/issues/23.
* If you are using macOS and get an error saying that the ubuntu/xenial64 image doesn't
exist, please run `sudo rm -r /opt/vagrant/embedded/bin/curl`. This is usually due to
issues with the version of curl bundled with Vagrant.
* If you receive the error `default: cp: cannot open '/path/to/geth.ipc' for reading: Operation not supported` after running `vagrant up`, run `./raft-init.sh` within the 7nodes directory on your local machine.  This will remove temporary files created after running 7nodes locally and will enable `vagrant up` to execute correctly.  

#### Troubleshooting Vagrant: Memory usage
* The Vagrant instance is allocated 6 GB of memory.  This is defined in the `Vagrantfile`, `v.memory = 6144`.  This has been deemed a suitable value to allow the VM and examples to run as expected.  The memory allocation can be changed by updating this value and running `vagrant reload` to apply the change.

* If the machine you are using has less than 8 GB memory you will likely encounter system issues such as slow down and unresponsiveness when starting the Vagrant instance as your machine will not have the capacity to run the VM.  There are several steps that can be taken to overcome this:
    1. Shutdown any running processes that are not required
    1. If running the [7nodes example](examples/7nodes), reduce the number of nodes started up.  See the [7nodes: Reducing the number of nodes](#reducing-the-number-of-nodes) for info on how to do this.
    1. Set up and run the examples locally.  Running locally reduces the load on your memory compared to running in Vagrant.


### Running with Docker

1. Install Docker (https://www.docker.com/get-started)
    - If your Docker distribution does not contain `docker-compose`, follow [this](https://docs.docker.com/compose/install/) to install Docker Compose
    - Make sure your Docker daemon has at least 4G memory
    - Required Docker Engine 18.02.0+ and Docker Compose 1.21+
1. Download and run `docker-compose`
   ```sh
   git clone https://github.com/jpmorganchase/quorum-examples
   cd quorum-examples
   docker-compose up -d
   ```
1. By default, the Quorum network is created with Tessera privacy managers and Istanbul BFT consensus. To use Raft consensus, set the environment variable `QUORUM_CONSENSUS=raft` before running `docker-compose`. To start a Quorum node without its associated privacy transaction manager, set `PRIVATE_CONFIG=ignore`. `QUORUM_CONSENSUS` and `PRIVATE_CONFIG` can be set together.
   ```sh
   PRIVATE_CONFIG=ignore QUORUM_CONSENSUS=raft docker-compose up -d
   ```
1. Run `docker ps` to verify that all quorum-examples containers (7 nodes and 7 tx managers) are **healthy**
1. Run `docker logs <container-name> -f` to view the logs for a particular container
1. __Note__: to run the 7nodes demo, use the following snippet to open `geth` Javascript console to a desired node (using container name from `docker ps`) and send a private transaction
   ```sh
   $ docker exec -it quorum-examples_node1_1 geth attach /qdata/dd/geth.ipc
   Welcome to the Geth JavaScript console!

   instance: Geth/node1-istanbul/v1.7.2-stable/linux-amd64/go1.9.7
   coinbase: 0xd8dba507e85f116b1f7e231ca8525fc9008a6966
   at block: 70 (Thu, 18 Oct 2018 14:49:47 UTC)
    datadir: /qdata/dd
    modules: admin:1.0 debug:1.0 eth:1.0 istanbul:1.0 miner:1.0 net:1.0 personal:1.0 rpc:1.0 txpool:1.0 web3:1.0

   > loadScript('/examples/private-contract.js')
   ```
1. Shutdown Quorum Network
   ```sh
   docker-compose down
   ```

#### Troubleshooting Docker

1. Docker is frozen
    - Check if your Docker daemon is allocated enough memory (minimum 4G)
1. Tessera crashes due to missing file/directory
    - This is due to the location of `quorum-examples` folder is not shared
    - Please refer to Docker documentation for more details:
        - [Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/troubleshoot/#shared-drives)
        - [Docker Desktop for Mac](https://docs.docker.com/docker-for-mac/#file-sharing)
        - [Docker Machine](https://docs.docker.com/machine/overview/): this depends on what Docker machine provider is used. Please refer to its documentation on how to configure shared folders/drives
1. If you run Docker inside Docker, make sure to run the container with `--privileged`


### Running locally

**Note:** Quorum must be run on Ubuntu-based/macOS machines.  Constellation can only be run on Ubuntu-based machines.  Running the examples therefore requires an Ubuntu-based/macOS machine.  If running the examples using Constellation then an Ubuntu-based machine is required. 

1. Install [Golang](https://golang.org/dl/)
2. Download and build [Quorum](https://github.com/jpmorganchase/quorum/):
   
    ```sh
    git clone https://github.com/jpmorganchase/quorum
    cd quorum
    make
    GETHDIR=`pwd`; export PATH=$GETHDIR/build/bin:$PATH
    cd ..
    ```
    
3. Download and build Tessera (see [README](https://github.com/jpmorganchase/tessera) for build options)
   
    ```bash
    git clone https://github.com/jpmorganchase/tessera.git
    cd tessera
    mvn install
    ```
    
4. Download quorum-examples
    ```sh
    git clone https://github.com/jpmorganchase/quorum-examples
    ```


## Starting the 7nodes sample network

**Note:** This is not required if `docker-compose` has been used to prepare the network as the `docker-compose` command performs these actions for you
    
Shell scripts are included in the examples to make it simple to configure the network and start submitting transactions.

All logs and temporary data are written to the `qdata` folder.

The sample network can be created to run using Istanbul BFT, Raft or Clique POA consensus mechanisms.  In the following commands replace `{consensus}` with one of `raft`, `istanbul` or `clique` depending on the consensus mechanism you want to use.

1. Navigate to the 7nodes example directory, configure the Quorum nodes and initialize accounts & keystores:
    ```sh
    cd path/to/7nodes
    ./{consensus}-init.sh
    ```
1. Start the Quorum and privacy manager nodes (Constellation or Tessera):
    - If running in Vagrant:
        ```sh
        ./{consensus}-start.sh
        ```
        By default, Tessera will be used as the privacy manager.  To use Constellation run the following:
        ```
        ./{consensus}-start.sh constellation
        ```

    - If running locally:
        ```
        ./{consensus}-start.sh tessera --tesseraOptions "--tesseraJar /path/to/tessera-app.jar"
        ```
        
        By default, `{consensus}-start.sh` will look in `/home/vagrant/tessera/tessera-app/target/tessera-app-{version}-app.jar` for the Tessera jar.  `--tesseraOptions` must be provided so that the start script looks in the correct location for the Tessera jar: 

        Alternatively, the Tessera jar location can be specified by setting the environment variable `TESSERA_JAR`.

1. You are now ready to start sending private/public transactions between the nodes

1. To stop the network:
    ```bash
    ./stop.sh
    ``` 

## Running the example
`quorum-examples` includes some simple transaction contracts to demonstrate the privacy features of Quorum.  See the [7nodes Example](examples/7nodes) page for details on how to run them.

## Variations
### Reducing the number of nodes 
It is easy to reduce the number of nodes used in the example network.  You may want to do this for memory usage reasons or just to experiment with a different network configuration.

For example, to run the example with 5 nodes instead of 7, follow these steps:

1. Update the list of nodes involved in consensus
    * If using Raft
        1. Remove node 6 and node 7's enode addresses from `permissioned-nodes.json` (i.e. the entries with `raftport` `50406` and `50407`).  Ensure that there is no trailing comma on the last row of enode details in the file.
    * If using IBFT
        1. Find the 20-byte address representations of node 6 and node 7's nodekey (nodekeys located at `qdata/dd{i}/geth/nodekey`).  There are many ways to do this, one is to run a script making use of `ethereumjs-wallet`:
            ```node
            const wlt = require('ethereumjs-wallet');
            
            var nodekey = '1be3b50b31734be48452c29d714941ba165ef0cbf3ccea8ca16c45e3d8d45fb0';
            var wallet = wlt.fromPrivateKey(Buffer.from(nodekey, 'hex'));
            
            console.log('addr: ' + wallet.getAddressString());
            ```
        1. Use `istanbul-tools` to decode the `extraData` field in `istanbul-genesis.json`
            ```bash
            git clone https://github.com/jpmorganchase/istanbul-tools.git
            cd istanbul-tools
            make
            ./build/bin/istanbul extra decode --extradata <...>
            ```
        1. Copy the output into a new `.toml` file and update the formatting to the following:
            ```yaml
            vanity = "0x0000000000000000000000000000000000000000000000000000000000000000"
            validators = [
              "0xd8dba507e85f116b1f7e231ca8525fc9008a6966",
              "0x6571d97f340c8495b661a823f2c2145ca47d63c2",
              ...
            ]
            ```
        1. Remove the addresses of node 6 and node 7 from the validators list 
        1. Use `istanbul-tools` to encode the `.toml` as `extraData`
            ```bash
            ./build/bin/istanbul extra encode --config /path/to/conf.toml
            ```
        1. Update the `extraData` field in `istanbul-genesis.json` with output from the encoding 

1. After making these changes, the relevant init/start scripts can be run (replace `{consensus}` with the relevent consensus mechanism in the following):

   ```sh
   # ./{consensus}-init.sh --numNodes 5
   # ./{consensus}-start.sh
   ```

1. `private-contract.js` by default sends a transaction to node 7.  As node 7 will no longer be started this must be updated to instead send to node 5:

    1. Copy node 5's public key from `./keys/tm5.pub`
    
    2. Replace the existing `privateFor` in `private-contract.js` with the key copied from `tm5.pub` key, e.g.:
        ``` javascript
        var simple = simpleContract.new(42, {from:web3.eth.accounts[0], data: bytecode, gas: 0x47b760, privateFor: ["R56gy4dn24YOjwyesTczYa8m5xhP6hF2uTMCju/1xkY="]}, function(e, contract) {...}
        ```

You can then follow steps described above to verify that node 5 can see the transaction payload and that nodes 2-4 are unable to see the payload.

### Using a Tessera remote enclave
Tessera v0.9 introduced the ability to run the privacy manager's enclave as a separate process from the Transaction Manager. This is a more secure way of being able to manage and interact with your keys.  

To start a sample 7nodes network that uses remote enclaves run `./{consensus}-start.sh tessera-remote`. By default this will start 7 Transaction Managers, the first 4 of which use a remote enclave. If you wish to change this number, you will need to add the extra parameter `--remoteEnclaves X` in the `--tesseraOptions`, e.g. `./{consensus}-start.sh tessera-remote --tesseraOptions "--remoteEnclaves 7"`.

### Experimenting with alternative curves in Tessera
By default tessera uses the [NaCl(salt)](https://nacl.cr.yp.to/) library in order to encrypt private payloads.
If you would like to experiment with/use alternative curves/symmetric ciphers you can choose to configure the EC Encryptor (which relies on JCA to perform a similar logic to NaCl). 
The tessera initialization script uses the the following environment variables to generate the encryptor section of the tessera configuration file:

Environment Variable Name|Default Value|Description
-------------|-------------|-----------
ENCRYPTOR_TYPE|NACL|The encryptor type. Possible values are EC or NACL.
ENCRYPTOR_EC_ELLIPTIC_CURVE|secp256r1|The elliptic curve to use. See [SunEC provider](https://docs.oracle.com/javase/8/docs/technotes/guides/security/SunProviders.html#SunEC) for other options. Depending on the JCE provider you are using there may be additional curves available.
ENCRYPTOR_EC_SYMMETRIC_CIPHER|AES/GCM/NoPadding|The symmetric cipher to use for encrypting data (GCM IS MANDATORY as an initialisation vector is supplied during encryption).
ENCRYPTOR_EC_NONCE_LENGTH|24|The nonce length (used as the initialization vector - IV - for symmetric encryption).
ENCRYPTOR_EC_SHARED_KEY_LENGTH|32|The key length used for symmetric encryption (keep in mind the key derivation operation always produces 32 byte keys - so the encryption algorithm must support it).

Based on the default values above (provided ENCRYPTOR_TYPE is defined as EC) the following configuration entry is produced:
```json
...
    "encryptor": {
        "type":"EC",
        "properties":{
            "symmetricCipher":"AES/GCM/NoPadding",
            "ellipticCurve":"secp256r1",
            "nonceLength":"24",
            "sharedKeyLength":"32"
        }
    }
...
``` 
Example:
```shell script
export ENCRYPTOR_TYPE=EC
export ENCRYPTOR_EC_ELLIPTIC_CURVE=sect571k1
./raft-init.sh
```

### Next steps: Sending transactions
Some simple transaction contracts are included in quorum-examples to demonstrate the privacy features of Quorum.  To learn how to use them see the [7nodes README](examples/7nodes/README.md).

# Getting Help
Stuck at some step? Have no fear, the help is here: <a href="https://clh7rniov2.execute-api.us-east-1.amazonaws.com/Express/" target="_blank" rel="noopener"><img title="Quorum Slack" src="https://clh7rniov2.execute-api.us-east-1.amazonaws.com/Express/badge.svg" alt="Quorum Slack" /></a>
