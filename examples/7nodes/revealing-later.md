# Quorum privacy
## Workaround for revealing some data to additional recipients later

> its not currently possible to add a new participant to an existing private contract. It's one of the enhancements that we have in our backlog.

https://github.com/jpmorganchase/quorum-examples/issues/90#issuecomment-379514111

until then, this workaround does work for the *subset* of cases where the possible later viewers can be known ahead ... 

see https://github.com/jpmorganchase/quorum-examples/issues/90#issuecomment-379667024 and the following comments

## files added to this repo

* [revealing-later.md](revealing-later.md) = these instructions
* [init-private.js](init-private.js) = shortcut to initialize JSRE var with recently deployed contract
* [script2.js](script2.js) because:

> When you deploy the contract for the first time, you should update the privateFor fields in script1.js to include both keys: [...]


## strategy:
Notation: (A)lice = node 1, (B)ob = node 7, (C)arol = node 5

1. `A` deploys contract with `privateFor: [B, C]`  
2. `A` calls `set(13)` with `privateFor: [B]` - but not `C`   
3. `A` calls `set(get())` with `privateFor: [B,C]` 

Why?

* the data `13` can be temporarily hidden from some participants (here: `C`), until it is unlocked to them.

Consequences:

* C can not see the new data `13` after step 2.
* but C can now see the data `13` after step 3.
* C can probably not be sure that the data `13` at step 3 is actually the same data that it was after step 2. (anyone got a good idea, for how to solve this?)

Correct thinking? If not please [add to issue #90](https://github.com/jpmorganchase/quorum-examples/issues/90#issuecomment-378327035), thx.

## Step by Step

```
git clone https://github.com/drandreaskrueger/quorum-examples.git
cd quorum-examples
```

Start from scratch - approx 15 minutes to recreate VM  
(TODO: what would be a shortcut to destroy just the chain & anything related - but not the whole virtualbox?)
```
vagrant destroy # in case there was an older attempt
```

```
vagrant up
vagrant status
vagrant ssh
```

```
cd quorum-examples/7nodes
./raft-init.sh
./raft-start.sh
```

### step 1

```
./runscript.sh script2.js
exit
```

now we have the newly deployed (`script2.js`) contract from block 1 tx 0, with an access structure that includes Bob AND Carol.


Get three terminals, and (within `vagrant ssh`) start the JSRE consoles for Alice, Bob, and Carol:

```
for node in 1 7 5 
do
    gnome-terminal --tab -e 'vagrant ssh -c "geth attach ipc:/home/vagrant/quorum-examples/7nodes/qdata/dd'$node'/geth.ipc; exec /bin/bash -i"'
done
```

or manually 3 times, with `dd1`, `dd7`, `dd5`:
```
vagrant ssh
geth attach ipc:/home/vagrant/quorum-examples/7nodes/qdata/dd1/geth.ipc 
```

in *each* JSRE now:
```
web3.admin.datadir
var BLOCKNUMBER = null; loadScript('quorum-examples/7nodes/init-private.js')
private.get()
```

answers should be:

42 Alice  
42 Bob  
42 Carol  


### step 2.  Alice calls `set(13)` with `privateFor: [Bob]` - but not `Carol`

`set` from Alice (node 1)
```
private.set(13,{from:eth.coinbase,privateFor:["ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc="]});
```
wait a moment, until the block is sealed.

`get()` from Alice and Bob and Carol:
```
private.get()
```

answers should be:

13 Alice  
13 Bob  
42 Carol  

so Carol still sees the OLD value.

### step 3.  Alice calls `set(get())` with `privateFor: [Bob, Carol]`

`set(get())` from Alice (node 1)
```
BOBnCAROL=["R56gy4dn24YOjwyesTczYa8m5xhP6hF2uTMCju/1xkY=", "ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc="]
private.set(private.get(),{from:eth.coinbase, privateFor:BOBnCAROL});
```
wait a moment, until the block is sealed.

`get()` from Alice and Bob and Carol:
```
private.get()
```

answers should be:

13 Alice  
13 Bob  
13 Carol  

Hooray. Workaround ... works.

N.B.: Only if possible later collaborateurs are known initially already (when contract is deployed).


