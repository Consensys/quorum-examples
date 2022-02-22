package com.quorum.web3j.example;

import com.quorum.example.sol.SimpleStorage;
import org.web3j.protocol.admin.Admin;
import org.web3j.protocol.admin.methods.response.PersonalUnlockAccount;
import org.web3j.protocol.core.methods.response.*;
import org.web3j.protocol.http.HttpService;
import org.web3j.quorum.PrivacyFlag;
import org.web3j.quorum.Quorum;
import org.web3j.quorum.tx.ClientTransactionManager;

import java.math.BigInteger;
import java.util.Arrays;

/**
 * Deploy a private contract using web3 generated java code and the ClientTransactionManager.
 * Also demonstrates use of Privacy Flag and Mandatory Recipients.
 */
public class SendPrivateTransaction {
    private static final String TESSERA1_PUBLIC_KEY = "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=";

    private static final String TESSERA7_PUBLIC_KEY = "ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc=";

    public static void main(String[] args) throws Exception {
        // initialize web3j with the quorum RPC address
        final HttpService httpService = new HttpService("http://localhost:22000");

        Admin admin = Admin.build(httpService);
        Quorum quorum = Quorum.build(httpService);

        // This uses ClientTransactionManager with 'on node' signing, using the specified account.
        final EthAccounts ethAccounts = quorum.ethAccounts().send();
        final String ethFirstAccount = ethAccounts.getAccounts().get(0);
        System.out.println("Using eth account " + ethAccounts.getAccounts());

        final PersonalUnlockAccount personalUnlockAccount = admin.personalUnlockAccount(ethFirstAccount, "").send();
        if (!personalUnlockAccount.accountUnlocked()) {
            throw new IllegalStateException("Account " + ethFirstAccount + " can not be unlocked!");
        }

        ClientTransactionManager clientTransactionManager = new ClientTransactionManager(quorum, ethFirstAccount, TESSERA1_PUBLIC_KEY, Arrays.asList(TESSERA1_PUBLIC_KEY, TESSERA7_PUBLIC_KEY), PrivacyFlag.MANDATORY_FOR, Arrays.asList(TESSERA7_PUBLIC_KEY), 30, 1000);

        SimpleStorage ssContract = SimpleStorage.deploy(quorum,
                clientTransactionManager,
                BigInteger.valueOf(0),
                BigInteger.valueOf(4300000),
                BigInteger.valueOf(42)).send();

        System.out.println("Contract address:" + ssContract.getContractAddress());
        System.out.println(ssContract.getTransactionReceipt());
    }
}