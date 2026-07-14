// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract multiSignWallet{
    address[] public owners;
    mapping(address => bool) public isOwner;

    uint public required;
    
    struct Transaction{
        address to;
        uint value;
        bool executed;
        uint approvalCount;
    }

    Transaction[] public transactions;

    mapping(uint => mapping(address => bool)) public approved;

    modifier onlyOwner{
        require(isOwner[msg.sender],"Access Denied only Owner!");
        _;
    }

    modifier txExist(uint txId){
        require(transactions.length>txId,"Transaction does not exist!");
        _;
    }

    modifier notExecuted(uint txId){
        require(!transactions[txId].executed,"Transaction already executed!");
        _;
    }

    modifier notApproved(uint txId){
        require(!approved[txId][msg.sender],"Transaction already approved!");
        _;
    }
 
    constructor(address[] memory _owners, uint _required){
        require(_owners.length > 0,"Owners required!");
       require(
            _required > 0 && _required <= _owners.length,
            "Invalid required approvals"
        );

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];

            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {}

    function submitTransaction(address _to)
        external payable
        onlyOwner
    {
        transactions.push(
            Transaction({
                to: _to,
                value: msg.value,
                executed: false,
                approvalCount: 0
            })
        );
    }

    function approveTransaction(uint txId)
        external
        onlyOwner
        txExist(txId)
        notExecuted(txId)
        notApproved(txId)
    {
        approved[txId][msg.sender] = true;
        transactions[txId].approvalCount++;
    }

    function executeTransaction(uint txId)
        external
        onlyOwner
        txExist(txId)
        notExecuted(txId)
    {
        Transaction storage transaction = transactions[txId];

        require(
            transaction.approvalCount >= required,
            "Not enough approvals"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}("");

        require(success, "Transaction failed");
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() external view returns (uint) {
        return transactions.length;
    }
}