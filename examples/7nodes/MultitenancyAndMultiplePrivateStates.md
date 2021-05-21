# Multiple private states
## Set Up
Either build locally or pull docker images for both go-quorum and tessera which support multitenancy and multiple private states.

Note: the "develop" tag should support the necessary features.

Bring up the network using docker compose:
```shell script
docker-compose -f docker-compose-4nodes-mps.yml up
```

The above sets up quorum node1 with keys key1, key5, key6 and key7 as node managed accounts. It also sets up tessera node1 with tm1, tm5, tm6 and tm7 keys and starts the network.

This is the residentGroups configuration on node1:
```json
    "residentGroups":[
        {
            "name":"private",
            "description":"default privacy group",
            "members":["BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo="]
        },
        {
            "name":"PS1",
            "description":"Privacy Group 1",
            "members":["R56gy4dn24YOjwyesTczYa8m5xhP6hF2uTMCju/1xkY="]
        },
        {
            "name":"PS2",
            "description":"Privacy Group 2",
            "members":["UfNSeSGySeKg11DVNEnqrUtxYRVor4+CvluI8tVv62Y="]
        },
        {
            "name":"PS3",
            "description":"Privacy Group 3",
            "members":["ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc="]
        }
    ],

```

## Exercising multiple states
### Accumulator contract
The following contract will be used to highlight the different states the contrat can be in on node1. 
Use `acc-contact.js` to deploy the contract for all node1's public keys. 
```solidity
pragma solidity ^0.5.0;

contract accumulator {
  uint public storedData;

  event IncEvent(uint value);

  constructor(uint initVal) public {
    storedData = initVal;
  }

  function inc(uint x) public {
    storedData = storedData + x;
    emit IncEvent(storedData);
  }

  function get() view public returns (uint retVal) {
    return storedData;
  }
}
```

### Console setup

Open 4 consoles to node1 (in order to take advantage of the latest APIs please use a geth binary that supports multiple private states):

* Console1 - using the "private" state - key1 (BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=) 
```shell script
geth attach http://localhost:22000
```
* Console2 - using the "PS1" state - key5 (R56gy4dn24YOjwyesTczYa8m5xhP6hF2uTMCju/1xkY=) 
```shell script
geth attach http://localhost:22000/?PSI=PS1
```
* Console3 - using the "PS2" state - key6 (UfNSeSGySeKg11DVNEnqrUtxYRVor4+CvluI8tVv62Y=) 
```shell script
geth attach http://localhost:22000/?PSI=PS2
```
* Console4 - using the "PS3" state - key7 (ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc=) 
```shell script
geth attach http://localhost:22000/?PSI=PS3
```

Open one console to node4:

```shell script
geth attach http://localhost:22003
```

### Steps
#### Deploy the contract and check the state in every console
On the node4 console run:
```shell script
> loadScript('acc-contract.js')


Contract transaction send: TransactionHash: 0xe0e0e199f16dfe9c0a59724d5a9759e670934fb80b35fa8fdd2a03a3636dcebd waiting to be mined...
true
Contract mined! Address: 0x180893a0ec847fa8c92786791348d7d65916acbb
```

On every console run:
```javascript
var address = "0x180893a0ec847fa8c92786791348d7d65916acbb";
var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"inc","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"name":"value","type":"uint256"}],"name":"IncEvent","type":"event"}];
var acc = eth.contract(abi).at(address)
acc.IncEvent().watch( function (error, log) {
    console.log("\nIncEvent details:")
    console.log("    NewValue:", log.args.value)
});
acc.get()
```
The `acc.IncEvent().watch(...)` creates the relevant filter for the InvEvent and then starts watching for new events. Confirm that the state of the contract in all consoles (except for Console4/PS3 where the contract is not deployed) is 1.

#### Invoke `acc.inc()` on a subset of the original participants
On node4's console do (increment for key1, key5):
```javascript
acc.inc(1,{from:eth.accounts[0],privateFor:["BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=", "R56gy4dn24YOjwyesTczYa8m5xhP6hF2uTMCju/1xkY="]});
``` 
On Console1 and Console2 you should see:

```
IncEvent details:
    NewValue: 2
```

Do an `acc.get()` in all consoles. You should get 2 Console1 and Console2, 1 in Console3 and 0 in Console 4.

On node4's console do (increment for key1):
```javascript
acc.inc(1,{from:eth.accounts[0],privateFor:["BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo="]});
``` 

Do an `acc.get()` in all consoles. You should get `3` in node1 consoles 1, `2` in node1 console 2, `1` node1 console 3, `0` in node1 console 4 and `3` in node4's console.

Do an `eth.getTransactionReceipt("0x34f881b717ddb3b1ab05fb948d375b593f4c74576258915e06a7f9cd9d0d15f4")` (the last transaction from node4) in all consoles and observe the different results (similar to the observed states above).

Do an `eth.getQuorumPayload(eth.getTransaction("0xe0e0e199f16dfe9c0a59724d5a9759e670934fb80b35fa8fdd2a03a3636dcebd").input)` (try to get the private payload of the contract creation transaction) on all consoles. On all of them except for Console4/PS3 you should get the contract bytecode while on Console4 you should get an empty result. 

# Multitenancy with multiple private states
## Set Up
Similar to the multiple private states example with the exception that node1 is started as a multitenant node and the rpc security plugin is enabled/configured.
An OAUTH2 server is also deployed in order to facilitate generating the necessary access tokens. 

Bring up the network using docker compose:
```shell script
docker-compose -f docker-compose-4nodes-mt.yml up
```

## Connecting to the multitenant node
Use the `mtAttachWithPSI.sh` script to connect to node1 as any of the 4 tenants (private, PS1, PS2, PS3).
The script configures the relevant access for the tenant on the OAUTH2 server and then requests a token. It then uses the token to attach (`geth attach`) to node1. 
The parameters are:
* The private state one wants to access. This parameter is mandatory.
* The node managed eth account to use for transaction signing (the tenant is restricted to that account only). This parameter is optional. 
```shell
./mtAttachWithPSI.sh PS1 
```
or
```shell
./mtAttachWithPSI.sh PS1 0x0638e1574728b6d862dd5d3a3e0942c3be47d996 
```
Once attached you can exercise the private state the same as as in the multiple private states example. Keep in mind the additional restrictions deriving from the access token (the node managed eth account access).