# Java Examples

## Compilation

From the send-private-txn-java folder run:
```
mvn clean install
``` 
## Running
Make sure to compile first. Each example should display information (hash/receipt) about the newly created transaction 
or the error that caused the failure. 
##### SendRawPrivateTransaction 
```
mvn exec:java -Dexec.cleanupDaemonThreads=false -Dexec.mainClass=com.quorum.web3j.example.SendRawPrivateTransaction

```
##### SendRawPrivateTransactionExternalSigning
```
mvn exec:java -Dexec.cleanupDaemonThreads=false -Dexec.mainClass=com.quorum.web3j.example.SendRawPrivateTransactionExternalSigning

```
##### SendRawPrivateTransactionWithQTM
```
mvn exec:java -Dexec.cleanupDaemonThreads=false -Dexec.mainClass=com.quorum.web3j.example.SendRawPrivateTransactionWithQTM

```
