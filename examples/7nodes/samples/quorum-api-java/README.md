# Java Examples

## Compilation

From the send-private-txn-java folder run:
```
mvn clean install
``` 
## Running
Make sure to compile first. Each example should display consensus/permission information for each of rpc methods called 
##### IstanbulRpcExample
```
mvn exec:java -Dexec.cleanupDaemonThreads=false -Dexec.mainClass=com.quorum.web3j.example.IstanbulRpcExample

```
##### RaftRpcExample
```
mvn exec:java -Dexec.cleanupDaemonThreads=false -Dexec.mainClass=com.quorum.web3j.example.RaftRpcExample

```
##### PermissioningExample
Follow steps in sample code