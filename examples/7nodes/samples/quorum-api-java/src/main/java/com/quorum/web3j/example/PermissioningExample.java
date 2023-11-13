package com.quorum.web3j.example;

import java.io.IOException;
import java.math.BigInteger;
import java.util.List;

import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.http.HttpService;
import org.web3j.quorum.Quorum;
import org.web3j.quorum.methods.request.PrivateTransaction;
import org.web3j.quorum.methods.response.permissioning.ExecStatusInfo;
import org.web3j.quorum.methods.response.permissioning.OrgDetails;
import org.web3j.quorum.methods.response.permissioning.PermissionAccountInfo;
import org.web3j.quorum.methods.response.permissioning.PermissionNodeInfo;
import org.web3j.quorum.methods.response.permissioning.PermissionOrgInfo;
import org.web3j.quorum.methods.response.permissioning.PermissionRoleInfo;

public class PermissioningExample {
	
	public static void main(String[] args) {
		
		//this example uses a modified 7nodes 'start-permission.sh raft' to bring up the first 4 nodes in a permissioned network
		//node6 will have 2 accounts (key6 and key8)
		//this example follows the permission usage documentation (https://docs.goquorum.com/en/latest/Permissioning/Usage/)
		//fill in the quorum connection details below
		
        String quorum1Url = "http://localhost:22000";
        String quorum2Url = "http://localhost:22001";
        String quorum3Url = "http://localhost:22002";
        String quorum4Url = "http://localhost:22003";
        
        Quorum quorum1 = Quorum.build(new HttpService(quorum1Url));
        Quorum quorum2 = Quorum.build(new HttpService(quorum2Url));
        
        //each node has an account - fill in details below
        //accounts on node1 and node2 are admin accounts of network
        
        String node1Account = "0xed9d02e382b34818e88b88a309c7fe71e65f419d";
        String node2Account = "0xca843569e3427144cead5e4d5999a3d0ccf92b8e";
        
		//will be creating 3 new nodes to add to the network (node5, node6, node7)
        
        try {
        	
        	//first will print out network details of our network using apis from node1
        	
        	List<PermissionOrgInfo> orgInfoList = quorum1.quorumPermissionGetOrgList().send().getPermissionOrgList();
        	System.out.println("OrgInfoList: " + orgInfoList);
        	
        	List<PermissionNodeInfo> nodeList = quorum1.quorumPermissionGetNodeList().send().getPermissionNodeList();
        	System.out.println("NodeList: " + nodeList);
        	
        	List<PermissionAccountInfo> acctList = quorum1.quorumPermissionGetAccountList().send().getPermissionAccountList();
        	System.out.println("AccountList: " + acctList);
        	
        	List<PermissionRoleInfo> roleList = quorum1.quorumPermissionGetRoleList().send().getPermissionRoleList();
        	System.out.println("RoleList: " + roleList);
        	
        	OrgDetails orgInfo = quorum1.quorumPermissionGetOrgDetails("ADMINORG").send().getOrgDetails();
        	System.out.println("OrgInfo for ADMINORG: " + orgInfo);
        	
        	
        	/* add and approve a new org in the network */
        	
        	//first create a new node with an address and get its enode and connection details
        	//can use details of node5 in 7nodes example
        	
        	String quorum5Url = "http://localhost:22004";       	
        	String node5Enode = "enode://3701f007bfa4cb26512d7df18e6bbd202e8484a6e11d387af6e482b525fa25542d46ff9c99db87bd419b980c24a086117a397f6d8f88e74351b41693880ea0cb@127.0.0.1:21004?discport=0&raftport=50405";
        	String node5Account = "0x0638e1574728b6d862dd5d3a3e0942c3be47d996";
        	
        	//use these details to add this node to the permissioned network as part of new org "ORG1"
        	
        	//create a transaction from node1 and use node5 details
        	PrivateTransaction tx1 = createTransactionFromAddress(quorum1, node1Account);	
        	ExecStatusInfo info = quorum1.quorumPermissionAddOrg("ORG1", node5Enode, node5Account, tx1).send();
        	printExecStatusDetails(info);
        	
        	Thread.sleep(3000);
        	
        	//use the 2nd admin account on node2 to approve the addition of node5
        	PrivateTransaction tx2a = createTransactionFromAddress(quorum2, node2Account);
        	ExecStatusInfo info2 = quorum2.quorumPermissionApproveOrg("ORG1", node5Enode, node5Account, tx2a).send();
        	printExecStatusDetails(info2);
        	
        	Thread.sleep(3000);
        	
        	//since need majority approval, use the 1st admin account on node1 to provide approval
        	PrivateTransaction tx2b = createTransactionFromAddress(quorum1, node1Account);
        	ExecStatusInfo info3 = quorum1.quorumPermissionApproveOrg("ORG1", node5Enode, node5Account, tx2b).send();
        	printExecStatusDetails(info3);
        	
        	Thread.sleep(3000);

        	
        	//check that the new account was added
        	System.out.println("AccountList After Add: " + quorum1.quorumPermissionGetAccountList().send().getPermissionAccountList());
        	
        	//add node5 to raft
        	System.out.println("raftid: " + quorum1.raftAddPeer(node5Enode).send().getAddedPeer());
        	
        	/*------------------------------------------------------------------------------------------*/
        	
        	/*	now we can start up node5 and have it join the network
        		1. cp qdata/dd1/permissioned-nodes.json qdata/dd5/permissioned-nodes.json
        		2. start up node with --raftjoinexisting flag (use permission-startNode5.sh) */
        	
        	
        	/*  creating a new suborg and adding a role, account and node to it */
        	
        	//node5Account is the admin of "ORG1" and create new suborgs
        	//create another new node with an address and get its enode
        	//can use details of node6 in 7nodes example
        	
        	String quorum6Url = "http://localhost:22005";
        	String node6Enode = "enode://eacaa74c4b0e7a9e12d2fe5fee6595eda841d6d992c35dbbcc50fcee4aa86dfbbdeff7dc7e72c2305d5a62257f82737a8cffc80474c15c611c037f52db1a3a7b@127.0.0.1:21005?discport=0&raftport=50406";
        	String node6Account = "0xae9bc6cd5145e67fbd1887a5145271fd182f0ee7"; 
        	
        	//add node6 to the permissioned network as part of sub org "ORG1.SUB1" using node5 ORG1 admin account

        	Quorum quorum5 = Quorum.build(new HttpService(quorum5Url));
        	
        	PrivateTransaction tx4 = createTransactionFromAddress(quorum5, node5Account);	
        	ExecStatusInfo info4 = quorum5.quorumPermissionAddSubOrg("ORG1", "SUB1", "", tx4).send();
        	printExecStatusDetails(info4);
        	
        	Thread.sleep(3000);
        	
        	//add a SUBADMIN role to the sub org
        	PrivateTransaction tx5 = createTransactionFromAddress(quorum5, node5Account);
        	ExecStatusInfo info5 = quorum5.quorumPermissionAddNewRole("ORG1.SUB1", "SUBADMIN", 3, false, true, tx5).send();
        	printExecStatusDetails(info5);
        	
        	Thread.sleep(3000);
        	
        	//assign SUBADMIN role of the sub org to node6 account
        	PrivateTransaction tx6 = createTransactionFromAddress(quorum5, node5Account);
        	ExecStatusInfo info6 = quorum5.quorumPermissionAddAccountToOrg(node6Account, "ORG1.SUB1", "SUBADMIN", tx6).send();
        	printExecStatusDetails(info6);
        	
        	Thread.sleep(3000);
        	
        	//add node6 to the sub org
        	PrivateTransaction tx4a = createTransactionFromAddress(quorum5, node5Account);
        	quorum5.quorumPermissionAddNode("ORG1.SUB1", node6Enode, tx4a).send().getExecStatus();
        	
        	Thread.sleep(3000);
        	
        	//check the sub org details
        	System.out.println("SubOrg Details: " + quorum1.quorumPermissionGetOrgDetails("ORG1.SUB1").send().getOrgDetails());
        	
        	//add node6 to raft
        	System.out.println("raftid: " + quorum1.raftAddPeer(node6Enode).send().getAddedPeer());
        	
        	/*------------------------------------------------------------------------------------------*/
        	
        	/*	now we can start up node6 and have it join the network
        		1. cp qdata/dd1/permissioned-nodes.json qdata/dd6/permissioned-nodes.json
        		2. start up node with --raftjoinexisting flag (use permission-startNode6.sh) */
        	
        	Quorum quorum6 = Quorum.build(new HttpService(quorum6Url));

        	PrivateTransaction tx7 = createTransactionFromAddress(quorum6, node6Account);
	        ExecStatusInfo info7 = quorum6.quorumPermissionAddNewRole("ORG1.SUB1", "TRANSACT", 1, false, true, tx7).send();
	        printExecStatusDetails(info7);
        	
        	Thread.sleep(3000);
	        
	        //check role list for sub org
	        System.out.println("subOrg role Details: " + quorum1.quorumPermissionGetOrgDetails("ORG1.SUB1").send().getOrgDetails().component1());
        	
	        //create another account on node6
	        String node6Account2 = "0xa9e871f88cbeb870d32d88e4221dcfbd36dd635a";
	        
	        //add this new account to the subOrg
	        PrivateTransaction tx8 = createTransactionFromAddress(quorum1, node6Account);
        	ExecStatusInfo info8 = quorum6.quorumPermissionAddAccountToOrg(node6Account2, "ORG1.SUB1", "SUBADMIN", tx8).send();
        	printExecStatusDetails(info8);
        	
        	Thread.sleep(3000);
        	
        	//check has been updated in accounts
        	System.out.println("subOrg account Details: " + quorum1.quorumPermissionGetOrgDetails("ORG1.SUB1").send().getOrgDetails().component2());
        	
        	//suspend node6Account2 from sub org which changes the accounts status
        	PrivateTransaction tx9 = createTransactionFromAddress(quorum1, node6Account);
        	ExecStatusInfo info9 = quorum6.quorumPermissionUpdateAccountStatus("ORG1.SUB1", node6Account2, 1, tx9).send();
        	printExecStatusDetails(info9);
        	
        	Thread.sleep(3000);
        	
        	//check status has been updated in accounts
        	System.out.println("subOrg account Details: " + quorum1.quorumPermissionGetOrgDetails("ORG1.SUB1").send().getOrgDetails().component2());
        	
        	/* add a new node (node7) to sub org */
        	
        	//create a new node with an address and get its enode address and connection details
        	//can use details of node7 in 7nodes example
        	String quorum7Url = "http://localhost:22006";
        	String node7Enode = "enode://239c1f044a2b03b6c4713109af036b775c5418fe4ca63b04b1ce00124af00ddab7cc088fc46020cdc783b6207efe624551be4c06a994993d8d70f684688fb7cf@127.0.0.1:21006?discport=0&raftport=50407";
        	String node7Account = "0xcc71c7546429a13796cf1bf9228bff213e7ae9cc";
        	
        	//add the new node to the sub org
        	PrivateTransaction tx10 = createTransactionFromAddress(quorum6, node6Account);
        	ExecStatusInfo info10 = quorum6.quorumPermissionAddNode("ORG1.SUB1", node7Enode, tx10).send();
        	printExecStatusDetails(info10);
        	
        	Thread.sleep(3000);
        	
        	//check node has been added to sub org nodeList
        	System.out.println("subOrg node Details: " + quorum1.quorumPermissionGetOrgDetails("ORG1.SUB1").send().getOrgDetails().component3());
        	
        	//to deactivate the new node - update node status
        	PrivateTransaction tx11 = createTransactionFromAddress(quorum1, node6Account);
        	ExecStatusInfo info11 = quorum6.quorumPermissionUpdateNodeStatus("ORG1.SUB1", node7Enode, 1, tx11).send();
        	printExecStatusDetails(info11);
        	
        	Thread.sleep(3000);
        	
        	//check status has been updated
        	System.out.println("subOrg node Details: " + quorum1.quorumPermissionGetOrgDetails("ORG1.SUB1").send().getOrgDetails().component3());
        	
        	/* suspending and unsuspending an org using org admin accounts */
        	
        	//use admin account of node1 to suspend the org
        	PrivateTransaction tx12 = createTransactionFromAddress(quorum1, node1Account);
        	ExecStatusInfo info12 = quorum1.quorumPermissionUpdateOrgStatus("ORG1", 1, tx12).send();
        	printExecStatusDetails(info12);
        	
        	Thread.sleep(3000);
        	
        	//use admin account of node2 to approve suspension
        	PrivateTransaction tx13 = createTransactionFromAddress(quorum2, node2Account);
        	ExecStatusInfo info13 = quorum2.quorumPermissionApproveOrgStatus("ORG1", 1, tx13).send();
        	printExecStatusDetails(info13);
        	
        	Thread.sleep(3000);
        	
        	//use admin account of node1 to provide majority approval
        	PrivateTransaction tx13b = createTransactionFromAddress(quorum1, node1Account);
        	ExecStatusInfo info13b = quorum1.quorumPermissionApproveOrgStatus("ORG1", 1, tx13b).send();
        	printExecStatusDetails(info13b);
        	
        	Thread.sleep(3000);
        	
        	//check status of org
        	System.out.println("Org List: " + quorum1.quorumPermissionGetOrgList().send().getPermissionOrgList());
        	
        	//revoke suspension using node1 admin account
        	PrivateTransaction tx14 = createTransactionFromAddress(quorum1, node1Account);	
        	ExecStatusInfo info14 = quorum1.quorumPermissionUpdateOrgStatus("ORG1", 2, tx14).send();
        	printExecStatusDetails(info14);
        	
        	Thread.sleep(3000);
        	
        	//approve revoke of suspension using node2 admin account
        	PrivateTransaction tx15 = createTransactionFromAddress(quorum2, node2Account);   	
        	ExecStatusInfo info15 = quorum2.quorumPermissionApproveOrgStatus("ORG1", 2, tx15).send();
        	printExecStatusDetails(info15);
        	
        	Thread.sleep(3000);
        	
        	//approve revoke of suspension using node1 admin account
        	PrivateTransaction tx15b = createTransactionFromAddress(quorum1, node1Account);	
        	ExecStatusInfo info15b = quorum1.quorumPermissionApproveOrgStatus("ORG1", 2, tx15b).send();
        	printExecStatusDetails(info15b);
        	
        	Thread.sleep(3000);
        	
        	System.out.println("Org list: " + quorum1.quorumPermissionGetOrgList().send().getPermissionOrgList());
        	
        	/* assign admin privileges */
        	
        	//assign org1 admin priviledge to node5Account by node1Account
        	PrivateTransaction tx16 = createTransactionFromAddress(quorum1, node1Account);
        	ExecStatusInfo info16 = quorum1.quorumPermissionAssignAdminRole("ORG1", node5Account, "ADMIN", tx16).send();
        	printExecStatusDetails(info16);
        	
        	Thread.sleep(3000);
        	
        	//approve admin role by node2Account
        	PrivateTransaction tx17 = createTransactionFromAddress(quorum2, node2Account);
        	ExecStatusInfo info17 = quorum2.quorumPermissionApproveAdminRole("ORG1", node5Account, tx17).send();
        	printExecStatusDetails(info17);
        	
        	Thread.sleep(3000);
        	
        	//admin role by node1 for majority approval
        	PrivateTransaction tx17b = createTransactionFromAddress(quorum1, node1Account);
        	ExecStatusInfo info17b = quorum1.quorumPermissionApproveAdminRole("ORG1", node5Account, tx17b).send();
        	printExecStatusDetails(info17b);
        	
        	Thread.sleep(3000);
        	
        	//check node5Account has admin privileges for org1
        	System.out.println("Account list: " + quorum1.quorumPermissionGetAccountList().send().getPermissionAccountList());
        	  	
        } catch (Exception e) {
        	e.printStackTrace();
        }

	}
    private static PrivateTransaction createTransactionFromAddress(Quorum quorum, String address) throws IOException {
    	BigInteger nonce = quorum.ethGetTransactionCount(address, DefaultBlockParameterName.LATEST).send().getTransactionCount();
    	return new PrivateTransaction(address, nonce, BigInteger.valueOf(4700000), null, BigInteger.ZERO, null, null, null);
    	
    }
    
    private static void printExecStatusDetails(ExecStatusInfo info) {
    	System.out.println("Status: " + info.getExecStatus());
    	String err = info.getError() != null ? info.getError().getMessage() : "none";
    	System.out.println("Error: " + err);
    }

}
