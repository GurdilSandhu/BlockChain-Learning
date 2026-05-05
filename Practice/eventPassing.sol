// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract eventPassing{
    uint balance;
    uint wallet;

    event deposit(uint amount);
    event accounts(address indexed acc, uint amount);

    function depositAmount(uint amount) public{
        balance += amount;

        emit deposit(amount);
    }

    function withdrawAmount(uint amount) public{
        balance -= amount;
    }

    function account() public payable{
           emit accounts(msg.sender,msg.value);
    }
}