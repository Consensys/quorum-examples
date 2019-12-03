package com.quorum.web3j.example;

import java.math.BigInteger;
import java.util.List;

import org.web3j.protocol.Web3jService;
import org.web3j.protocol.http.HttpService;
import org.web3j.quorum.Quorum;
import org.web3j.quorum.methods.response.raft.RaftPeer;

public class RaftRpcExample {

    public static void main(String[] args) {

        String quorumUrl = "http://localhost:22000";
        Web3jService web3jService = new HttpService(quorumUrl);
        Quorum quorum = Quorum.build(web3jService);

        try {
            // raft role
            String r = quorum.raftGetRole().send().getRole();
            System.out.println("role " + r);

            // raft leader
            String l = quorum.raftGetLeader().send().getLeader();
            System.out.println("leader " + l);

            // raft cluster
            List<RaftPeer> cluster = quorum.raftGetCluster().send().getCluster().get();
            System.out.println("cluster size " + cluster.size());
            System.out.println("cluster " + cluster);

            // raft remove peer
            int raftId = 7;
            String removed = quorum.raftRemovePeer(raftId).send().getNoResponse();
            System.out.println("remove " + removed);
            Thread.sleep(3000);
            List<RaftPeer> clusterPostRemove = quorum.raftGetCluster().send().getCluster().get();
            System.out.println("cluster size after remove " + clusterPostRemove.size());

            // raft add peer
            String enode =
                    "enode://239c1f044a2b03b6c4713109af036b775c5418fe4ca63b04b1ce00124af00ddab7cc088fc46020cdc783b6207efe624551be4c06a994993d8d70f684688fb7cf@127.0.0.1:21006?discport=0&raftport=50407";
            BigInteger addedPeer = quorum.raftAddPeer(enode).send().getAddedPeer();
            System.out.println("added peer " + addedPeer);
            Thread.sleep(2000);
            List<RaftPeer> clusterPostAdd = quorum.raftGetCluster().send().getCluster().get();
            System.out.println("cluster size after add: " + clusterPostAdd.size());

            // now can start up node 7 with --raftjoinexisting 8 flag
        	

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
