var src = 'contract SendBalance { mapping ( address => uint ) userBalances ; bool withdrawn = false ; function getBalance (address u) constant returns ( uint ){ return userBalances [u]; } function addToBalance () { userBalances[msg.sender] += msg.value ; } function withdrawBalance (){ if (!(msg.sender.call.gas(0x1111).value ( userBalances [msg . sender ])())) { throw ; } userBalances [msg.sender ] = 0; } }';
var compiled = web3.eth.compile.solidity(src);
var root = Object.keys(compiled)[0];
var contract = web3.eth.contract(compiled[root].info.abiDefinition);
var c = contract.new(42, {from:web3.eth.accounts[0], data: compiled[root].code, gas: 300000, privateFor: ["ROAZBWtSacxXQrOe3FGAqJDyJjFePR5ce4TSIzmJ0Bc="]}, function(e, contract) {
	if (e) {
		console.log("err creating contract", e);
	} else {
		if (!contract.address) {
			console.log("Contract transaction send: TransactionHash: " + contract.transactionHash + " waiting to be mined...");
		} else {
			console.log("Vulnerable contract mined! Address: " + contract.address);
			console.log(contract);
		}
	}
});
