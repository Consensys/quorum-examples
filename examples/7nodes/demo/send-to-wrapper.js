var address = "0xe10681ccf3452138a4b8226e583bbc8919dd2439";

var abi = [{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"constant":false,"inputs":[{"internalType":"uint256","name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"}];

var priv = eth.contract(abi).at(address);

priv.set(10, {from: eth.accounts[0]});