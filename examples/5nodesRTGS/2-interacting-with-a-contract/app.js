import $ from 'jquery';
import Web3 from 'web3quorum';

// Instance Web3 using localhost testrpc
const web3regulator = new Web3(new Web3.providers.HttpProvider("http://IP:22003"));
const web3bank1 = new Web3(new Web3.providers.HttpProvider("http://IP:22000"));
const web3bank2 = new Web3(new Web3.providers.HttpProvider("http://IP:22001"));
const web3bank3 = new Web3(new Web3.providers.HttpProvider("http://IP:22002"));

// This is an interface of the MyToken contract, called ABI, that we will interact with it
const BankContractABI = require('./MyBank.json');
const TrLogContractABI = require('./MyTrLog.json');

const bank1Contract = web3bank1.eth.contract(BankContractABI);
const bank2Contract = web3bank2.eth.contract(BankContractABI);
const bank3Contract = web3bank3.eth.contract(BankContractABI);

const regBank1Contract = web3regulator.eth.contract(BankContractABI);
const regBank2Contract = web3regulator.eth.contract(BankContractABI);
const regBank3Contract = web3regulator.eth.contract(BankContractABI);


const TrLogContract = web3regulator.eth.contract(TrLogContractABI);

var mainRegulatorAccount;
var mainBank1Account;
var mainBank2Account;
var mainBank3Account;

var bank1ContractAddress;
var bank2ContractAddress;
var bank3ContractAddress;
var trContractAddress;

//Update and uncomment these lines to hardcode the contract addresses. It saves a lot of time copy and pasting
/*
bank1ContractAddress = "0x180893a0ec847fa8c92786791348d7d65916acbb";
bank2ContractAddress = "0xf9a2cb34b6b5fd7a2ac0c2e9b2b9406d6daffbd4";
bank3ContractAddress = "0xc8f717ba9593dc9d45c4518cf444d2cbd08af24d";
trContractAddress = "0x4df0f115551f6f36d753dc0ecf6832715bdd7001";
*/ 
var bank1NodePublicKey = "BULeR8JyUWhiuuCMU/HLA0Q5pzkYT+cHII3ZKBey3Bo=";
var bank2NodePublicKey = "QfeDAys9MPDs2XHExtc84jKGHxZg/aj52DTh0vtA3Xc=";
var bank3NodePublicKey = "oNspPPgszVUFw0qmGFfWwh1uxVUXgvBxleXORHj07g8=";
var regNodePublicKey = "R56gy4dn24YOjwyesTczYa8m5xhP6hF2uTMCju/1xkY=";


var trContractInstance;
var bank1ContractInstance;
var bank2ContractInstance;
var bank3ContractInstance;

var senderContractInstance;
var destinationContractInstance;

var regBank1ContractInstance;
var regBank2ContractInstance;
var regBank3ContractInstance;

trContractInstance = TrLogContract.at(trContractAddress);
bank1ContractInstance = bank1Contract.at(bank1ContractAddress);
bank2ContractInstance = bank2Contract.at(bank2ContractAddress);
bank3ContractInstance = bank3Contract.at(bank3ContractAddress);

regBank1ContractInstance = regBank1Contract.at(bank1ContractAddress);
regBank2ContractInstance = regBank2Contract.at(bank2ContractAddress);
regBank3ContractInstance = regBank3Contract.at(bank3ContractAddress);


var regSenderContractInstance;

var trTxHash;
var confTxHash;



// We will use this function to show the status of the deployed token sale contract
const synchSmartContract = () => {

  let balance1;
  let balance2;
  let balance3;
  
  let trHash1;
  let trDetails1;

  let trHash2;
  let trDetails2;
  

  let trHash3;
  let trDetails3;

  let transactionLog;
  

  let trId1 = $('#bank1-transaction-id').val();
  let trId2 = $('#bank2-transaction-id').val();
  let trId3 = $('#bank3-transaction-id').val();
  
  let trSearch = $('#tr-search-hash').val();
  

  
   
  
  bank1ContractAddress = $('#bank1-contract-address').val();
  bank2ContractAddress = $('#bank2-contract-address').val();
  bank3ContractAddress = $('#bank3-contract-address').val();
  trContractAddress = $('#tr-contract-address').val(); 

  
  trContractInstance = TrLogContract.at(trContractAddress);
  bank1ContractInstance = bank1Contract.at(bank1ContractAddress);
  bank2ContractInstance = bank2Contract.at(bank2ContractAddress);
  bank3ContractInstance = bank3Contract.at(bank3ContractAddress);

  regBank1ContractInstance = regBank1Contract.at(bank1ContractAddress);
  regBank2ContractInstance = regBank2Contract.at(bank2ContractAddress);
  regBank3ContractInstance = regBank3Contract.at(bank3ContractAddress);
 
  balance1 = bank1ContractInstance.balance();
  balance2 = bank2ContractInstance.balance();
  balance3 = bank3ContractInstance.balance();
  
  trHash1 = bank1ContractInstance.transactionIDs(trId1);
  trDetails1 = bank1ContractInstance.transactions(trHash1);

  trHash2 = bank2ContractInstance.transactionIDs(trId2);
  trDetails2 = bank2ContractInstance.transactions(trHash2);
  

  trHash3 = bank3ContractInstance.transactionIDs(trId3);
  trDetails3 = bank3ContractInstance.transactions(trHash3);
  
  transactionLog = trContractInstance.transactions(trSearch);
  
   
  $('#bank1-balance').html(`<p><span class="address">Contract Address:${bank1ContractAddress}</span> </p> <p> <span class="balance">Balance: ${balance1}</span></p>`);
  $('#bank2-balance').html(`<p><span class="address">Contract Address:${bank2ContractAddress}</span> </p> <p> <span class="balance">Balance: ${balance2}</span></p>`);
  $('#bank3-balance').html(`<p><span class="address">Contract Address:${bank3ContractAddress}</span> </p> <p> <span class="balance">Balance: ${balance3}</span></p>`);
  
  $('#bank1-tr-hash').html(`<p><span class="hash">Transaction Hash:${trHash1}</span></p>
  <p><span class="hash">Value:${trDetails1[0]}</span></p>
  <p><span class="hash">Sender Address:${trDetails1[1]}</span></p>
  <p><span class="hash">Destination Address:${trDetails1[2]}</span></p>
  <p><span class="hash">Confirmed:${trDetails1[3]}</span></p>`);

  $('#bank2-tr-hash').html(`<p><span class="hash">Transaction Hash:${trHash2}</span></p>
  <p><span class="hash">Value:${trDetails2[0]}</span></p>
  <p><span class="hash">Sender Address:${trDetails2[1]}</span></p>
  <p><span class="hash">Destination Address:${trDetails2[2]}</span></p>
  <p><span class="hash">Confirmed:${trDetails2[3]}</span></p>`);

  $('#bank3-tr-hash').html(`<p><span class="hash">Transaction Hash:${trHash3}</span></p>
  <p><span class="hash">Value:${trDetails3[0]}</span></p>
  <p><span class="hash">Sender Address:${trDetails3[1]}</span></p>
  <p><span class="hash">Destination Address:${trDetails3[2]}</span></p>
  <p><span class="hash">Confirmed:${trDetails3[3]}</span></p>`);
  
  $('#tr-contract-addr').html(`<p><span class="address">Address:${trContractAddress}</span></p>`);
  
  
  console.log  (transactionLog[1]);

  let d = new Date(transactionLog[1]/1000);

  $('#transaction-log').html(`<p> <span class="exists">ID:${trSearch}</span>\n
   <span class="exists">Exists:${transactionLog[0]}\n
   <span class="timestamp">Timestamp: ${d.toString()}</span>\n
   <span class="timestamp">Blocked: ${transactionLog[2]}</span></p>`);

};

// We will use this function to show the status of the accounts generated by testRPC
const synchAccounts = () => {
  //$('#gas-price').html(`<b>Gas: ETH ${web3regulator.eth.gasPrice}</b>`);

    
  $('#regulator-account').html("");
  web3regulator.eth.accounts.forEach(account => {
    let balance = web3regulator.eth.getBalance(account);
    mainRegulatorAccount = account;
    $('#regulator-account').append(`<p> <span class="address">${account}</span> | <span class="balance">ETH ${balance}</span></p>`);
  });

  $('#bank1-account').html("");
  web3bank1.eth.accounts.forEach(account => {
    let balance = web3bank1.eth.getBalance(account);
    mainBank1Account = account;
    $('#bank1-account').append(`<p> <span class="address">${account}</span> | <span class="balance">ETH ${balance}</span></p>`);
  });

  $('#bank2-account').html("");
  web3bank2.eth.accounts.forEach(account => {
    let balance = web3bank1.eth.getBalance(account);
    mainBank2Account = account;
    $('#bank2-account').append(`<p> <span class="address">${account}</span> | <span class="balance">ETH ${balance}</span></p>`);
  });

  $('#bank3-account').html("");
  web3bank3.eth.accounts.forEach(account => {
    let balance = web3bank1.eth.getBalance(account);
    mainBank3Account = account;
    $('#bank3-account').append(`<p> <span class="address">${account}</span> | <span class="balance">ETH ${balance}</span></p>`);
  });


};

// This callback just avoids us to copy & past every time you want to use an address
const updateAddressFromLink = (event, inputSelector) => {
  event.preventDefault();
  $(inputSelector).val($(event.target).siblings(".address").text());
};


// Show initial accounts state and initialize callback triggers
synchSmartContract();
synchAccounts();
$(document).on('change', '#bank1-contract-address', e => synchSmartContract());
$(document).on('change', '#bank2-contract-address', e => synchSmartContract());
$(document).on('change', '#bank3-contract-address', e => synchSmartContract());
$(document).on('change', '#tr-contract-address', e => synchSmartContract());

$(document).on('change', '#bank1-transaction-id', e => synchSmartContract());
$(document).on('change', '#bank2-transaction-id', e => synchSmartContract());
$(document).on('change', '#bank3-transaction-id', e => synchSmartContract());

$(document).on('change', '#tr-search-hash', e => synchSmartContract());

$(document).on('change', '#tr-contract-address', e => synchSmartContract());


$(document).on('click', '.from', e => updateAddressFromLink(e, '#seller-address'));
$(document).on('click', '.to', e => updateAddressFromLink(e, '#buyer-address'));
$(document).on('click', '.transaction', e => updateTransactionInfoFromLink(e));

// Every time we click the buy button, we will
$('#send').click(() => {
  let sentValue = $('#sent-value').val();
  let senderAddress = $('#sender-address').val();
  let destinationAddress = $('#destination-address').val();
  let bankContractAddress = $('#contract-address').val();
  let correctSender = false;
  let correctDestination = false;
  
  
  let destinationNodePublicKey;
  let senderAccount;
  /* let trContractAddress = "0x180893a0ec847fa8c92786791348d7d65916acbb"
  let bank1ContractAddress = "0xf9a2cb34b6b5fd7a2ac0c2e9b2b9406d6daffbd4";
  destinationAddress = "0xc8f717ba9593dc9d45c4518cf444d2cbd08af24d";
   */

  $('#transaction-hash').html(`<p>Private Money Transfer</p>`);
  
  
  if (senderAddress == bank1ContractAddress) {
    senderContractInstance = bank1ContractInstance;
    senderAccount = mainBank1Account;
    correctSender = true;
  }
  if (senderAddress == bank2ContractAddress) {
    senderContractInstance = bank2ContractInstance;
    senderAccount = mainBank2Account;
    correctSender = true;
  }
  if (senderAddress == bank3ContractAddress) {
    senderContractInstance = bank3ContractInstance;
    senderAccount = mainBank3Account;
    correctSender = true;
  }

  if (destinationAddress == bank1ContractAddress) {
    destinationNodePublicKey = bank1NodePublicKey;
    destinationContractInstance = bank1ContractInstance;
    correctDestination = true;
  }
  if (destinationAddress == bank2ContractAddress) {
    destinationNodePublicKey = bank2NodePublicKey;
    destinationContractInstance = bank2ContractInstance;
    correctDestination = true;
  }
  if (destinationAddress == bank3ContractAddress) {
    destinationNodePublicKey = bank3NodePublicKey;
    destinationContractInstance = bank3ContractInstance;
    correctDestination = true;
  }

  console.log(senderAddress);
  console.log(destinationAddress);
  console.log(bank3ContractAddress);


  if (correctSender && correctDestination) {
    senderContractInstance.sendValue(destinationAddress,sentValue,"random1",
    {from:senderAccount,gas:500000,
      privateFor:[regNodePublicKey,destinationNodePublicKey]},
      function (e, receipt){
        //This function will execute when the transaction is mined
        console.log(e);
      let senderTransactionNumber = senderContractInstance.totalTransactions()-1;
      let destinationTransactionNumber = destinationContractInstance.totalTransactions()-1;
        
      let newTrHash = senderContractInstance.transactionIDs(senderTransactionNumber);
      
      $('#transaction-hash').html(`<p>Private Money Transfer Details:</p>`);
      $('#transaction-hash').append(`<p>Sender Transaction ID:${senderTransactionNumber}</p>`);
      $('#transaction-hash').append(`<p>Destination Transaction ID:${destinationTransactionNumber}</p>`);
      $('#transaction-hash').append(`<p>Private Money Transfer TX Hash:${newTrHash}</p>`);
      $('#transaction-hash').append(`<p>Warning:TX Hash must be in the public transaction log to be confirmed</p>`);        
      $('#transactions-list').append(`<p><class="transaction">${receipt}</a></p>`);
      
    });
  }
  else {
    $('#transaction-hash').html(`<p>Something went wrong! Please check addresses.</p>`);
  }
    
  synchSmartContract();
  synchAccounts();
});

$('#tr-add-button').click(() => {
  trTxHash = $('#tr-add-hash').val();

  trContractInstance.addTransaction(trTxHash,{from:mainRegulatorAccount,gas:500000},
    function (e, receipt){
      //This function will execute when the transaction is mined
    let transaction = trContractInstance.transactions(trTxHash);

    //The transaction was successfully logged in the Public Transaction Log? This check does not work, and I do not know why, of course!!!!
    if (transaction[0]) {
      $('#tr-add-result').html(`<p>Transaction ${trTxHash} successfully included in the transaction log</p>`);  
    }
    else {
      $('#tr-add-result').html(`<p>Hopefully it was successfull, but you need to check manually using the "Search Public Transaction Log" just above. My code for checking if the TxHash was included is not working, I think the world state is not being updated fast enough, even after the receipt, where this check executes. Any help is appreciated. :)</p>`);  
    }
    $('#transactions-list').append(`<p><class="transaction">${receipt}</a></p>`);
  });

});

$('#tr-conf-button').click(() => {
  confTxHash = $('#tr-conf-hash').val();
  let trSender = $('#tr-sender').val();

  let senderNodePublicKey;
  let destinationNodePublicKey;
  
  if (trSender == bank1ContractAddress) {
    regSenderContractInstance = regBank1ContractInstance;
    senderNodePublicKey = bank1NodePublicKey;
  }
  if (trSender == bank2ContractAddress) {
    regSenderContractInstance = regBank2ContractInstance;
    senderNodePublicKey = bank2NodePublicKey;
  }
  if (trSender == bank3ContractAddress) {
    regSenderContractInstance = regBank3ContractInstance;
    senderNodePublicKey = bank3NodePublicKey;
  }

  let transaction = regSenderContractInstance.transactions(confTxHash);
  //need to discover the recipient of the transaction to set privateFor public key correctly
  if (transaction[2] == bank1ContractAddress) {
    destinationNodePublicKey = bank1NodePublicKey;
  }
  if (transaction[2] == bank2ContractAddress) {
    destinationNodePublicKey = bank2NodePublicKey;
  }
  if (transaction[2] == bank3ContractAddress) {
    destinationNodePublicKey = bank3NodePublicKey;
  }

  regSenderContractInstance.confirmTransactionRegulator(confTxHash,{from:mainRegulatorAccount,gas:500000,
    privateFor:[senderNodePublicKey,destinationNodePublicKey]},
    function (e, receipt){
      //This function will execute when the transaction is mined
    let transaction = regSenderContractInstance.transactions(confTxHash);

    //The transaction was successfully logged in the Public Transaction Log? This check does not work, and I do not know why, of course!!!!
    if (transaction[3]) {
      $('#tr-conf-result').html(`<p>Transaction ${trTxHash} successfully confirmed</p>`);  
    }
    else {
      $('#tr-conf-result').html(`<p>Hopefully it was successfull, but you need to check balances manually refreshing the page and see if the balance has changed. My code for checking if the TxHash was included is not working, I think the world state is not being updated fast enough, even after the receipt, where this check executes. Any help is appreciated. :)</p>`);  
    }
    $('#transactions-list').append(`<p><class="transaction">${receipt}</a></p>`);
  });

 

});
