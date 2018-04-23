# running quroum on host machine, not in vagrant VB
because [suggested here](https://github.com/jpmorganchase/quorum/issues/346)


```
vagrant destroy
cd examples/7nodes/
```

moving away the vanilla geth:

```
which geth
geth version
sudo mv $(which geth) $(which geth)_vanilla
```

quorum geth:
```
../../../../quorum/quorum-2.0.2/build/bin/geth version
```
> Version: 1.7.2-stable  
> Quorum Version: 2.0.1  
> ...

```
sudo cp ../../../../quorum/quorum-2.0.2/build/bin/geth /usr/local/bin/geth_quorum
ln -s /usr/local/bin/geth_quorum /usr/local/bin/geth
geth version
```

```
./raft-init.sh
```

TODO: continue here.

Now see https://github.com/drandreaskrueger/quorum-examples/tree/master/non-vagrant because pull-request to jpm repo.
