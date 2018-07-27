// From geth console run
//   $> loadScript('event_test.js')
// From console test node 1 & 7 to see if the events were recorded
//   $> seth events 0x1932c48b2bf8102ba33b4a6b545c32236e342f34 | wc -l
// 0x1932c48b2bf8102ba33b4a6b545c32236e342f34
//var address="0xd6b20677a5e4d464caa68b518327f63485df071a"// "0x1932c48b2bf8102ba33b4a6b545c32236e342f34"
//var address="0x1932c48b2bf8102ba33b4a6b545c32236e342f34"
var address = "0x244e29801a30e791f5338d5aafff67678d08f052"
// simple contract
var abi = [{"constant":true,"inputs":[],"name":"storedData","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"x","type":"uint256"}],"name":"set","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"get","outputs":[{"name":"retVal","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"initVal","type":"uint256"}],"payable":false,"type":"constructor"}];
var contract = eth.contract(abi).at(address)

for ( i = 0; i < 20; i++) {
  contract.set(4,{from:eth.accounts[0]});
}
