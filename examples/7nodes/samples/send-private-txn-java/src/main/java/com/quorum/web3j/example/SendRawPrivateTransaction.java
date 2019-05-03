package com.quorum.web3j.example;

import com.quorum.example.sol.SimpleStorage;
import okhttp3.OkHttpClient;
import org.web3j.crypto.Credentials;
import org.web3j.crypto.WalletUtils;
import org.web3j.protocol.http.HttpService;
import org.web3j.quorum.Quorum;
import org.web3j.quorum.enclave.Enclave;
import org.web3j.quorum.enclave.Tessera;
import org.web3j.quorum.enclave.protocol.EnclaveService;
import org.web3j.quorum.tx.QuorumTransactionManager;

import java.math.BigInteger;
import java.util.Arrays;

/**
 * Sends a raw private transaction using web3 generated java code and the QuorumTransactionManager.
 */
public class SendRawPrivateTransaction {
    private static final String TESSERA1_PUBLIC_KEY = "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=";

    private static final String TESSERA7_PUBLIC_KEY = "ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc=";

    public static void main(String[] args) throws Exception {
        // initialize web3j with the quorum RPC address
        Quorum quorum = Quorum.build(new HttpService("http://localhost:22000"));
        // initialize the enclave service using the tessera ThirdParty app URL
        EnclaveService enclaveService = new EnclaveService("http://localhost", 9081, new OkHttpClient());
        // initialize the tessera enclave
        Enclave enclave = new Tessera(enclaveService, quorum);

        // load the account from the filesystem
        Credentials credentials = WalletUtils.loadCredentials("", "../../keys/key1");

        // create a quorum transaction manager
        // This object (used by the generated code) does the following:
        // 1. sends the raw payload to tessera and retrieves the txHash
        // 2. replace the transaction payload with the received txHash
        // 3. create and sign a raw transaction using the provided credentials
        // 4. invoke the eth_SendRawPrivateTransaction API to send the transaction to quorum
        QuorumTransactionManager qrtxm = new QuorumTransactionManager(quorum,
                credentials,
                TESSERA1_PUBLIC_KEY,
                Arrays.asList(TESSERA7_PUBLIC_KEY),
                enclave,
                30,
                1000);

        SimpleStorage ssContract = SimpleStorage.deploy(quorum,
                qrtxm,
                BigInteger.valueOf(0),
                BigInteger.valueOf(4300000),
                BigInteger.valueOf(42)).send();

        System.out.println("Contract address:" + ssContract.getContractAddress());
        System.out.println(ssContract.getTransactionReceipt());
    }
}
