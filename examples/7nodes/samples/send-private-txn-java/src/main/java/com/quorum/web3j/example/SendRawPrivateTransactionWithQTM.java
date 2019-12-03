package com.quorum.web3j.example;

import okhttp3.OkHttpClient;
import org.web3j.abi.FunctionEncoder;
import org.web3j.crypto.Credentials;
import org.web3j.crypto.RawTransaction;
import org.web3j.crypto.TransactionEncoder;
import org.web3j.crypto.WalletUtils;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.response.EthGetTransactionCount;
import org.web3j.protocol.core.methods.response.EthSendTransaction;
import org.web3j.protocol.core.methods.response.TransactionReceipt;
import org.web3j.protocol.http.HttpService;
import org.web3j.quorum.Quorum;
import org.web3j.quorum.enclave.Enclave;
import org.web3j.quorum.enclave.SendResponse;
import org.web3j.quorum.enclave.Tessera;
import org.web3j.quorum.enclave.protocol.EnclaveService;
import org.web3j.quorum.tx.QuorumTransactionManager;
import org.web3j.rlp.*;
import org.web3j.tx.response.PollingTransactionReceiptProcessor;
import org.web3j.utils.Numeric;

import java.math.BigInteger;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;

/**
 * Sends a raw private transaction using the RawTransactionManger's storeRawRequest and  sendRawRequest.
   Uses the QuorumTransactionManager methods to sign and send a raw private transaction.
 */
public class SendRawPrivateTransactionWithQTM {
    private static final String TESSERA1_PUBLIC_KEY = "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=";

    private static final String TESSERA7_PUBLIC_KEY = "ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc=";

    public static void main(String[] args) throws Exception {
        // initialize web3j with the quorum RPC address
        Quorum quorum = Quorum.build(new HttpService("http://localhost:22000"));
        // initialize the enclave service using the tessera ThirdParty app URL
        EnclaveService enclaveService = new EnclaveService("http://localhost", 9081, new OkHttpClient());
        Enclave enclave = new Tessera(enclaveService, quorum);

        // load the account from the filesystem
        Credentials credentials = WalletUtils.loadCredentials("", "../../keys/key1");

        // create a quorum transaction manager
        QuorumTransactionManager qtm = new QuorumTransactionManager(quorum,
                credentials,
                TESSERA1_PUBLIC_KEY,
                Arrays.asList(TESSERA7_PUBLIC_KEY),
                enclave);

        PollingTransactionReceiptProcessor pollingTransactionReceiptProcessor = new PollingTransactionReceiptProcessor(quorum, 1000, 10);

        // build the raw transaction payload
        String simpleStorageContractBytecode = "608060405234801561001057600080fd5b506040516020806101018339810180604052602081101561003057600080fd5b505160005560be806100436000396000f3fe6080604052348015600f57600080fd5b5060043610604e577c0100000000000000000000000000000000000000000000000000000000600035046360fe47b1811460535780636d4ce63c14606f575b600080fd5b606d60048036036020811015606757600080fd5b50356087565b005b6075608c565b60408051918252519081900360200190f35b600055565b6000549056fea165627a7a72305820733b6551c438b5cf89595bb7fdbb0774cc9e625b7e4ca0bce5c9c3d3bac264ae0029";
        String encodedConstructor = FunctionEncoder.encodeConstructor(Arrays.asList(new org.web3j.abi.datatypes.generated.Uint256(42)));
        String binaryAndInitCode = simpleStorageContractBytecode + encodedConstructor;
        String simpleStorageSetBytecode = "60fe47b10000000000000000000000000000000000000000000000000000000000000016";


        /* deploy contract again using a single QuorumTransactionManager methods */
        EthGetTransactionCount txCount1 = quorum.ethGetTransactionCount(credentials.getAddress(), DefaultBlockParameterName.LATEST).send();

        RawTransaction rawTx1 = RawTransaction.createTransaction(BigInteger.valueOf(txCount1.getTransactionCount().intValue()),
                BigInteger.ZERO, BigInteger.valueOf(4300000), "", BigInteger.ZERO, binaryAndInitCode);

        // send the signed transaction to quorum
        EthSendTransaction sentTx1 = qtm.signAndSend(rawTx1);
        String txHash1 = sentTx1.getTransactionHash();
        System.out.println("Transaction hash: " + txHash1);

        // poll for the transaction receipt
        TransactionReceipt transactionReceipt1 = pollingTransactionReceiptProcessor.waitForTransactionReceipt(txHash1);
        System.out.println("Transaction receipt: " + transactionReceipt1);

        /* deploy contract again using exposed QuorumTranasctionManager methods */

        // store the raw transaction payload in tessera
        SendResponse storeRawResponse = qtm.storeRawRequest(
                simpleStorageSetBytecode, TESSERA1_PUBLIC_KEY, Arrays.asList(TESSERA7_PUBLIC_KEY));

        System.out.println("Raw transaction hash from tessera:" + storeRawResponse.getKey());

        String tesseraTxHash = Numeric.toHexString(Base64.getDecoder().decode(storeRawResponse.getKey()));

        // find the current nonce for the account (for use in the next transaction)
        EthGetTransactionCount txCount2 = quorum.ethGetTransactionCount(credentials.getAddress(), DefaultBlockParameterName.LATEST).send();

        //create raw transaction with tessera tx hash
        RawTransaction rawTx2 = RawTransaction.createTransaction(BigInteger.valueOf(txCount2.getTransactionCount().intValue()),
                BigInteger.ZERO, BigInteger.valueOf(4300000), "", BigInteger.ZERO, tesseraTxHash);

        // build and sign private transaction
        String signedTxHex = qtm.sign(rawTx2);

        // send the signed transaction to quorum
        EthSendTransaction ethSendTransaction = qtm.sendRaw(signedTxHex, Arrays.asList(TESSERA7_PUBLIC_KEY));
        String txHash2 = ethSendTransaction.getTransactionHash();
        System.out.println("Transaction hash: " + txHash2);

        // poll for the transaction receipt
        TransactionReceipt transactionReceipt2 = pollingTransactionReceiptProcessor.waitForTransactionReceipt(txHash2);
        System.out.println("Transaction receipt: " + transactionReceipt2);

      }
}
