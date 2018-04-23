# running quorum on host machine, not in vagrant VB
because [suggested here](https://github.com/jpmorganchase/quorum/issues/346).

Better move away the vanilla `geth` (if there is one)
```
which geth
geth version
sudo mv $(which geth) $(which geth)_vanilla
```

### toolchain for quorum
(modelled after [../vagrant/bootstrap.sh](../vagrant/bootstrap.sh))

#### dependencies
```
sudo apt-get update
sudo apt-get install -y build-essential unzip libdb-dev libleveldb-dev libsodium-dev zlib1g-dev libtinfo-dev sysvbanner wrk wget
```

#### solc
... for installing on Debian / any Linux.  See [releases](https://github.com/ethereum/solidity/releases), I am choosing [Version 0.4.23](https://github.com/ethereum/solidity/releases/tag/v0.4.23).

```
wget https://github.com/ethereum/solidity/releases/download/v0.4.23/solc-static-linux
chmod a+x solc-static-linux
sudo mv solc-static-linux /usr/local/bin/solc
solc --version
```
> solc, the solidity compiler commandline interface  
> Version: 0.4.23+commit.124ca40d.Linux.g++  


#### constellation
```
CVER="0.3.2"
CREL="constellation-$CVER-ubuntu1604"
wget -q https://github.com/jpmorganchase/constellation/releases/download/v$CVER/$CREL.tar.xz
tar xfJ $CREL.tar.xz
sudo cp $CREL/constellation-node /usr/local/bin && chmod 0755 /usr/local/bin/constellation-node
rm -rf $CREL $CREL.tar.xz
constellation-node --version
```
> Constellation Node 0.3.2  

#### golang
```
GOREL=go1.9.3.linux-amd64.tar.gz
wget -q https://dl.google.com/go/$GOREL
tar xfz $GOREL
sudo rm -rf /usr/local/go
sudo mv go /usr/local/
rm -f $GOREL
PATH=$PATH:/usr/local/go/bin
echo 'PATH=$PATH:/usr/local/go/bin' >> $HOME/.bashrc
which go
go version
```
> /usr/local/go/bin/go  
> go version go1.7.3 linux/amd64  


#### quorum

```
cd ..
git clone https://github.com/jpmorganchase/quorum.git
cd quorum
git checkout tags/v2.0.1
make all
sudo cp build/bin/bootnode /usr/local/bin
sudo cp build/bin/geth /usr/local/bin/geth_quorum
ln -s -f /usr/local/bin/geth_quorum /usr/local/bin/geth
geth version
```
> Version: 1.7.2-stable  
> Git Commit: df4267a25637a5497a3db9fbde4603a3dcd6aa14  
> Quorum Version: 2.0.1  
> ...

### start 7 nodes

```
git clone https://github.com/drandreaskrueger/quorum-examples
cd quorum-examples
```

Possibly kill all virtualmachine `geth` instances (to e.g. free the ports 2200x) from previous attempts in vagrant VB:
```
vagrant destroy
```
or 
```
vagrant suspend
```

#### start raft
```
cd examples/7nodes/
rm qdata -rf

./raft-init.sh
./raft-start.sh
```

It is NOT starting up, error message is documented in [this issue](https://github.com/jpmorganchase/quorum/issues/352).


