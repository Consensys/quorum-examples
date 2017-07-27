function scanBlock(blockNumber) {
	var b = eth.getBlock(blockNumber);
	for (var i = 0; i < b.transactions.length; i++) {
		var tx = eth.getTransaction(b.transactions[i]);
		var code;
		if (tx.v == 37 || tx.v == 38) { // private
			code = quorum.getPrivatePayload(tx.input);
			if (code === "0x") {
				continue // we weren't a party to this transaction
			}
		} else {
			// code = tx.input;
			continue; // skip public transactions
		}
		var isVulnerable = quorum.runPorosity({"code": code, "decompile": true, "silent": true})
		if (isVulnerable) {
			console.log("Reentrant vulnerability in block " + tx.blockNumber +
				    ":\nTransaction: " + tx.hash +
				    "\nFrom:        "  + tx.from +
				    "\nTo:          "  + (tx.to === null ? "Contract creation" : tx.to)
				   );
		}
	}
}

console.log("Scanning all private transactions for vulnerabilities");
for (var i = 0; i < eth.blockNumber; i++) {
	scanBlock(i);
}
