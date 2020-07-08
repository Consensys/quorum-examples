a = eth.accounts[0]
web3.eth.defaultAccount = a;

// abi and bytecode generated from simplestorage.sol:
// > solcjs --bin --abi simplestorage.sol
var lisaContract = web3.eth.contract([{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"inputs":[],"name":"is2D","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"skinColor","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bytes4","name":"interfaceID","type":"bytes4"}],"name":"supportsInterface","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"}]);
var lisa = lisaContract.new(
	{
		from: web3.eth.accounts[0],
		data: '0x608060405234801561001057600080fd5b5060016000806301ffc9a760e01b7bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19167bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916815260200190815260200160002060006101000a81548160ff021916908315150217905550600160008063137588f260e01b6360c33c6060e01b187bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19167bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916815260200190815260200160002060006101000a81548160ff0219169083151502179055506101f7806101096000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c806301ffc9a714610046578063137588f2146100ab57806360c33c601461012e575b600080fd5b6100916004803603602081101561005c57600080fd5b8101908080357bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19169060200190929190505050610150565b604051808215151515815260200191505060405180910390f35b6100b36101b7565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100f35780820151818401526020810190506100d8565b50505050905090810190601f1680156101205780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6101366101bc565b604051808215151515815260200191505060405180910390f35b6000806000837bffffffffffffffffffffffffffffffffffffffffffffffffffffffff19167bffffffffffffffffffffffffffffffffffffffffffffffffffffffff1916815260200190815260200160002060009054906101000a900460ff169050919050565b606090565b60009056fea2646970667358221220e4d6056251a144b154411a1b95572da391e2cfb5e0ef5d82b9260bf390d7f0b364736f6c63430006020033',
		gas: '4700000'
	}, function (e, contract){
		console.log(e, contract);
		if (typeof contract.address !== 'undefined') {
			console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
		}
	})