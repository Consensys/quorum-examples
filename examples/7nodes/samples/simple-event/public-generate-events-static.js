// From console test node 1 & 7 to see if the events were recorded
// seth is a cool CLI (but you can use whatever you'd like): https://github.com/dapphub/dapptools
//   $> seth events 0x1932c48b2bf8102ba33b4a6b545c32236e342f34 | wc -l

// NOTE: replace this with the address of the contract you wish to generate
//       events for.
var address = "0x1932c48b2bf8102ba33b4a6b545c32236e342f34"

// simple contract
var abi = [{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"message","type":"string"},{"indexed":true,"internalType":"string","name":"extradata","type":"string"},{"indexed":false,"internalType":"uint256","name":"val","type":"uint256"}],"name":"UpdatedValue","type":"event"},{"inputs":[],"name":"get","outputs":[{"internalType":"uint256","name":"retVal","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"x","type":"uint256"}],"name":"set","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"storedData","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}];
var contract = eth.contract(abi).at(address)

for (var i = 0; i < 20; i++) {
  contract.set(4, {from:eth.accounts[0]});
}
