package com.quorum.web3j.example;

import java.util.List;
import java.util.Map;

import org.web3j.protocol.Web3jService;
import org.web3j.protocol.http.HttpService;
import org.web3j.quorum.Quorum;
import org.web3j.quorum.methods.response.istanbul.BlockSigners;
import org.web3j.quorum.methods.response.istanbul.Snapshot;


public class IstanbulRpcExample {

    public static void main(String[] args) {

        String quorumUrl = "http://localhost:22000";
        Web3jService web3jService = new HttpService(quorumUrl);
        Quorum quorum = Quorum.build(web3jService);

        String blockHash = "";

        try {
        	
        	//node address
        	String nodeAddress = quorum.istanbulNodeAddress().send().getNodeAddress();
        	System.out.println("nodeAddress: " + nodeAddress);
            
            //validators
            List<String> validators = quorum.istanbulGetValidators("latest").send().getValidators();
            System.out.println("validators " + validators);
            
//          List<String> validators2 = quorum.istanbulGetValidatorsAtHash(blockHash).send().getValidators();
//          System.out.println("validators2 at " + blockHash + ": " + validators2);
            
            //candidates
            Map<String, Boolean> candidates = quorum.istanbulCandidates().send().getCandidates();
            System.out.println("candidates " + candidates);
            
            // propose 1st validator
            if (validators != null && !validators.isEmpty()) {
                String candidateAddress = (String) validators.get(0);
                String propose =
                        quorum.istanbulPropose(candidateAddress, true).send().getNoResponse();
                System.out.println("proposal of " + candidateAddress + " was " + propose);
            }
            
            Map<String, Boolean> candidates2 = quorum.istanbulCandidates().send().getCandidates();
            System.out.println("candidates " + candidates2);
            
            // discard 1st validator
            if (validators != null && !validators.isEmpty()) {
                String candidateAddress = (String) validators.get(0);
                String propose = quorum.istanbulDiscard(candidateAddress).send().getNoResponse();
                System.out.println("discard of " + candidateAddress + " was " + propose);
            }
            
            Map<String, Boolean> candidates3 = quorum.istanbulCandidates().send().getCandidates();
            System.out.println("candidates " + candidates3);
            
        	//snapshot
            Snapshot snap = quorum.istanbulGetSnapshot("latest").send().getSnapshot().get();
            System.out.println("snap1 " + snap.toString());
            
//          Snapshot snap2 = quorum.istanbulGetSnapshotAtHash(blockHash).send().getSnapshot().get();
//          System.out.println("snap2 at " + blockHash + ": " + snap2.toString());
            
        	//block signers
        	BlockSigners blockSigners = quorum.istanbulGetSignersFromBlock("latest").send().getBlockSigners().get();
        	System.out.println("blockSigners " + blockSigners.toString());
        	
//        	BlockSigners blockSigners2 = quorum.istanbulGetSignersFromBlockByHash(blockHash).send().getBlockSigners().get();
//        	System.out.println("blockSigners2 at " + blockHash + ": " + blockSigners2.toString());

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
