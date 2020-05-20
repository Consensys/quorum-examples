pragma solidity ^0.6.0;

contract BankAccount {

    event DepositMade(uint256 amount, uint256 newBalance, string _date);
    event WithdrawalMade(uint256 amount, uint256 newBalance, string _date);

    string public customerName;

    uint256 public currentBalance;

    string public date;

    string lastTransactionMessage;

    constructor(string memory name) public {
        customerName = name;
        currentBalance = 0;
        date = "01/01/2020";
        lastTransactionMessage = "Initial opening";
    }

    function deposit(uint256 amount, string memory _date) public {
        currentBalance = currentBalance + amount;
        date = _date;

        lastTransactionMessage = "Bank deposit";

        emit DepositMade(amount, currentBalance, date);
    }

    function withdraw(uint256 amount, string memory _date) public {
        require(currentBalance > amount, "not enough money");

        currentBalance = currentBalance - amount;
        date = _date;

        lastTransactionMessage = "Bank withdrawal";

        emit DepositMade(amount, currentBalance, date);
    }

    function pay(uint256 amount, BankAccount target, string memory _date, string memory _reason) public {
       withdraw(amount, _date);

       target.receivePayment(amount, _date, _reason);

       lastTransactionMessage = _reason;
    }

    function receivePayment(uint256 amount, string memory _date, string memory _reason) public {
        deposit(amount, _date);

        lastTransactionMessage = _reason;
    }

}
