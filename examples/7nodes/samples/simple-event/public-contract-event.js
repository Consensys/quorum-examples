var simplestorageContract = web3.eth.contract([{"anonymous":false,"inputs":[{"indexed":false,"internalType":"string","name":"message","type":"string"},{"indexed":true,"internalType":"string","name":"extradata","type":"string"},{"indexed":false,"internalType":"uint256","name":"val","type":"uint256"}],"name":"UpdatedValue","type":"event"},{"inputs":[],"name":"get","outputs":[{"internalType":"uint256","name":"retVal","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"x","type":"uint256"}],"name":"set","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"storedData","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]);
var simplestorage = simplestorageContract.new(
    {
        from: web3.eth.accounts[0],
        data: '0x608060405234801561001057600080fd5b506101a5806100206000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c80632a1afcd91461004657806360fe47b1146100645780636d4ce63c14610092575b600080fd5b61004e6100b0565b6040518082815260200191505060405180910390f35b6100906004803603602081101561007a57600080fd5b81019080803590602001909291905050506100b6565b005b61009a610166565b6040518082815260200191505060405180910390f35b60005481565b8060008190555060405180807f437573746f6d206d657373616765000000000000000000000000000000000000815250600e01905060405180910390207fc4d4faa3583cff6682427526bd4968a4451408534deb408bce0b2bedde4fe49f826040518080602001838152602001828103825260128152602001807f56616c7565207570646174656420746f3a2000000000000000000000000000008152506020019250505060405180910390a250565b6000805490509056fea264697066735822122068da946445bafe6e4f1c176ca90d8ec730a55d80034c0d524459becd9240f7f064736f6c634300060a0033',
        gas: '4700000'
    }, function (e, contract){
        console.log(e, contract);
        if (typeof contract.address !== 'undefined') {
            console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
        }
    })