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
import org.web3j.rlp.*;
import org.web3j.tx.response.PollingTransactionReceiptProcessor;
import org.web3j.utils.Numeric;

import java.math.BigInteger;
import java.util.Arrays;
import java.util.Base64;
import java.util.Collections;

/**
 * Sends a raw private transaction using the RawTransactionManger's storeRawRequest and  sendRawRequest.
 * The transaction is composed without generated code and the signing code is clearly delimited and easy to replace
 * with external signing mechanism.
 */
public class SendRawPrivateTransactionExternalSigning {
    private static final String TESSERA1_PUBLIC_KEY = "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=";

    private static final String TESSERA7_PUBLIC_KEY = "ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc=";

    public static void main(String[] args) throws Exception {
        // initialize web3j with the quorum RPC address
        Quorum quorum = Quorum.build(new HttpService("http://localhost:22000"));
        // initialize the enclave service using the tessera ThirdParty app URL
        EnclaveService enclaveService = new EnclaveService("http://localhost", 9081, new OkHttpClient());
        Enclave enclave = new Tessera(enclaveService, quorum);

        // build the raw transaction payload
        String simpleStorageContractBytecode = "608060405234801561001057600080fd5b506040516020806101018339810180604052602081101561003057600080fd5b505160005560be806100436000396000f3fe6080604052348015600f57600080fd5b5060043610604e577c0100000000000000000000000000000000000000000000000000000000600035046360fe47b1811460535780636d4ce63c14606f575b600080fd5b606d60048036036020811015606757600080fd5b50356087565b005b6075608c565b60408051918252519081900360200190f35b600055565b6000549056fea165627a7a72305820733b6551c438b5cf89595bb7fdbb0774cc9e625b7e4ca0bce5c9c3d3bac264ae0029";
        String encodedConstructor = FunctionEncoder.encodeConstructor(Arrays.asList(new org.web3j.abi.datatypes.generated.Uint256(42)));
        String binaryAndInitCode = simpleStorageContractBytecode + encodedConstructor;

        // store the raw transaction payload in tessera
        SendResponse storeRawResponse = enclave.storeRawRequest(
                Base64.getEncoder().encodeToString(Numeric.hexStringToByteArray(binaryAndInitCode)),
                TESSERA1_PUBLIC_KEY, Collections.emptyList());

        System.out.println("Raw transaction hash from tessera:" + storeRawResponse.getKey());

        String tesseraTxHash = Numeric.toHexString(Base64.getDecoder().decode(storeRawResponse.getKey()));

        Credentials credentials = WalletUtils.loadCredentials("", "../../keys/key1");
        // find the current nonce for the account (for use in the next transaction)
        EthGetTransactionCount txCount = quorum.ethGetTransactionCount(credentials.getAddress(), DefaultBlockParameterName.LATEST).send();

        // build and sign transaction
        byte[] signedTxBytes = signTransactionUsingWeb3j(txCount.getTransactionCount().intValue(),
                0, 4300000, 0, tesseraTxHash, credentials);

        // set the private flag for the signed transaction
        signedTxBytes = setPrivate(signedTxBytes);

        String signedTxHex = Numeric.toHexString(signedTxBytes);

        // send the signed transaction to quorum
        EthSendTransaction ethSendTransaction = enclave.sendRawRequest(signedTxHex, Arrays.asList(TESSERA7_PUBLIC_KEY));
        String txHash = ethSendTransaction.getTransactionHash();
        System.out.println("Transaction hash: " + txHash);

        // poll for the transaction receipt
        PollingTransactionReceiptProcessor pollingTransactionReceiptProcessor = new PollingTransactionReceiptProcessor(quorum, 1000, 10);
        TransactionReceipt transactionReceipt = pollingTransactionReceiptProcessor.waitForTransactionReceipt(txHash);

        System.out.println("Transaction receipt: " + transactionReceipt);
    }

    // REPLACE THIS WITH YOUR MECHANISM FOR SIGNING TRANSACTIONS
    private static byte[] signTransactionUsingWeb3j(int nonce, int gasPrice, int gasLimit, int value, String data, Credentials credentials){
        RawTransaction rawTransaction = RawTransaction.createContractTransaction(BigInteger.valueOf(nonce),
                BigInteger.valueOf(gasPrice), BigInteger.valueOf(gasLimit), BigInteger.valueOf( value), data);
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
