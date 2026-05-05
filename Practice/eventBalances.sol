// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankEvents{
    
    mapping(address=> uint) public balances;

    event Balance(address account, uint balance);

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        emit Balance(msg.sender, msg.value);
    }

    function withdraw(uint amount) public payable {
        balances[msg.sender] -= amount;
        emit Balance(msg.sender, amount);
    }

}