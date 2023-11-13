package com.quorum.web3j.example;

import okhttp3.OkHttpClient;
import org.web3j.abi.FunctionEncoder;
import org.web3j.crypto.Credentials;
import org.web3j.crypto.RawTransaction;
import org.web3j.crypto.TransactionEncoder;
import org.web3j.crypto.WalletUtils;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.response.*;
import org.web3j.protocol.http.HttpService;
import org.web3j.quorum.PrivacyFlag;
import org.web3j.quorum.Quorum;
import org.web3j.quorum.enclave.Enclave;
import org.web3j.quorum.enclave.SendResponse;
import org.web3j.quorum.enclave.Tessera;
import org.web3j.quorum.enclave.protocol.EnclaveService;
import org.web3j.quorum.methods.response.EthAddress;
import org.web3j.quorum.tx.response.QuorumPollingTransactionReceiptProcessor;
import org.web3j.rlp.*;
import org.web3j.tx.response.PollingTransactionReceiptProcessor;
import org.web3j.utils.Numeric;

import java.math.BigInteger;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;

/**
 * Deploy a private contract using an externally signed Privacy Marker Transaction.
 * Also demonstrates use of Privacy Flag and Mandatory Recipients.
 */
public class SendRawPrivateTransactionExternalSigningPrivacyMarker {
    private static final String TESSERA1_PUBLIC_KEY = "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=";
    private static final String TESSERA3_PUBLIC_KEY = "1iTZde/ndBHvzhcl7V68x44Vx7pl8nwx9LqnM/AfJUg=";
    private static final String TESSERA7_PUBLIC_KEY = "ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc=";

    public static void main(String[] args) throws Exception {
        // initialize web3j with the quorum RPC address
        Quorum quorum = Quorum.build(new HttpService("http://localhost:22000"));
        // initialize the enclave service using the tessera ThirdParty app URL
        EnclaveService enclaveService = new EnclaveService("http://localhost", 9081, new OkHttpClient());
        Enclave enclave = new Tessera(enclaveService, quorum);

        Credentials credentials = WalletUtils.loadCredentials("", "../../keys/key1");

        // Get address of the privacy precompile contract
        EthAddress precompileAddress = quorum.ethGetPrivacyPrecompileAddress().send();
        System.out.println("Retrieved precompile address:" + precompileAddress.getAddress());

        // build the raw transaction payload
        final int valueToSet = 1961;
        String simpleStorageContractBytecode = "608060405234801561001057600080fd5b506040516101073803806101078339818101604052602081101561003357600080fd5b505160005560c1806100466000396000f3fe6080604052348015600f57600080fd5b5060043610603c5760003560e01c80632a1afcd914604157806360fe47b11460595780636d4ce63c146075575b600080fd5b6047607b565b60408051918252519081900360200190f35b607360048036036020811015606d57600080fd5b50356081565b005b60476086565b60005481565b600055565b6000549056fea265627a7a7231582086cef7b6c960e37608f020bdfdac3e51568d5333325973879fae2418aa2c307464736f6c63430005110032";
        String encodedConstructor = FunctionEncoder.encodeConstructor(Arrays.asList(new org.web3j.abi.datatypes.generated.Uint256(valueToSet)));
        String binaryAndInitCode = simpleStorageContractBytecode + encodedConstructor;

        // store the raw transaction payload in tessera
        SendResponse storeRawResponse = enclave.storeRawRequest(
                Base64.getEncoder().encodeToString(Numeric.hexStringToByteArray(binaryAndInitCode)),
                TESSERA1_PUBLIC_KEY, Collections.emptyList());
        System.out.println("Stored payload in Tessera, hash:" + storeRawResponse.getKey());
        String tesseraPayloadHash = Numeric.toHexString(Base64.getDecoder().decode(storeRawResponse.getKey()));

        // find the current nonce for the account (for use in the next transaction)
        EthGetTransactionCount txCount = quorum.ethGetTransactionCount(credentials.getAddress(), DefaultBlockParameterName.LATEST).send();
        int nonce = txCount.getTransactionCount().intValue();

        // build and sign private transaction
        RawTransaction rawPrivateTransaction = RawTransaction.createContractTransaction(BigInteger.valueOf(nonce),
                BigInteger.valueOf(0), BigInteger.valueOf(4300000), BigInteger.valueOf(0), tesseraPayloadHash);
        byte[] signedTxBytes = signTransactionUsingWeb3j(rawPrivateTransaction, credentials);
        signedTxBytes = setPrivate(signedTxBytes);  // set the private flag for the signed transaction
        String signedTxHex = Numeric.toHexString(signedTxBytes);

        // distribute the signed private transaction to participants, with Mandatory Recipient
        EthSendTransaction storePrivateTxnResponse = quorum.ethDistributePrivateTransaction(signedTxHex, Arrays.asList(TESSERA3_PUBLIC_KEY, TESSERA7_PUBLIC_KEY), PrivacyFlag.MANDATORY_FOR, Arrays.asList(TESSERA7_PUBLIC_KEY)).send();
        if (storePrivateTxnResponse.hasError()) {
            throw new Exception("Distribute Private Transaction failed, error = " + storePrivateTxnResponse.getError().getMessage());
        }
        String privateTxnHash = storePrivateTxnResponse.getTransactionHash();
        System.out.println("Private Transaction distributed, hash:" + privateTxnHash);

        // build and sign privacy marker transaction
        RawTransaction privacyMarkerTransaction = RawTransaction.createTransaction(BigInteger.valueOf(nonce),
                BigInteger.valueOf(0), BigInteger.valueOf(4300000), precompileAddress.getAddress(), privateTxnHash);
        byte[] signedPMTBytes = signTransactionUsingWeb3j(privacyMarkerTransaction, credentials);
        String signedPMTHex = Numeric.toHexString(signedPMTBytes);

        // send the privacy marker transaction to quorum
        EthSendTransaction ethSendTransaction = quorum.ethSendRawTransaction(signedPMTHex).send();

        String txHash = ethSendTransaction.getTransactionHash();
        if (txHash == null) {
            throw new Exception("Transaction failed (null txHash): check geth logs for cause");
        }

        // poll for the privacy marker transaction receipt (use Quorum poller, as that returns receipt with isPrivacyMarkerTransaction field)
        PollingTransactionReceiptProcessor pollingTransactionReceiptProcessor = new QuorumPollingTransactionReceiptProcessor(quorum, 1000, 10);
        TransactionReceipt pmtReceipt = pollingTransactionReceiptProcessor.waitForTransactionReceipt(txHash);
        System.out.println("Privacy Marker Transaction completed, receipt =\n" + pmtReceipt);
        // get the private transaction receipt
        EthGetTransactionReceipt privateTransactionReceipt = quorum.ethGetPrivateTransactionReceipt(txHash).send();
        System.out.println("Private transaction receipt =\n" + privateTransactionReceipt.getResult());
    }

    // REPLACE THIS WITH YOUR MECHANISM FOR SIGNING TRANSACTIONS
    private static byte[] signTransactionUsingWeb3j(RawTransaction rawTransaction, Credentials credentials){
        return TransactionEncoder.signMessage(rawTransaction, credentials);
    }

    // If the byte array RLP decodes to a list of size >= 1 containing a list of size >= 3
    // then find the 3rd element from the last. If the element is a RlpString of size 1 then
    // it should be the V component from the SignatureData structure -> mark the transaction as private.
    // If any of of the above checks fails then return the original byte array.
    private static byte[] setPrivate(byte[] message){
        byte[] result = message;
        RlpList rlpWrappingList = RlpDecoder.decode(message);
        if (!rlpWrappingList.getValues().isEmpty()) {
            RlpType rlpListObj = rlpWrappingList.getValues().get(0);
            if (rlpListObj instanceof RlpList) {
                RlpList rlpList = (RlpList) rlpListObj;
                int rlpListSize = rlpList.getValues().size();
                if (rlpListSize > 3) {
                    RlpType vFieldObj = rlpList.getValues().get(rlpListSize-3);
                    if (vFieldObj instanceof RlpString) {
                        RlpString vField = (RlpString) vFieldObj;
                        if (1 == vField.getBytes().length) {
                            if (vField.getBytes()[0] == 28){
                                vField.getBytes()[0] = 38;
                            } else {
                                vField.getBytes()[0] = 37;
                            }
                            result = RlpEncoder.encode(rlpList);
                        }
                    }
                }
            }
        }
        return result;
    }
}