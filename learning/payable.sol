// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract receive_Ether{
    address private owner;

    constructor(){
        owner = msg.sender;
    }

    modifier checkOwner{
        require(owner == msg.sender,"Access Denied");
        _;
    }

    mapping (address => uint) public balances;
    uint newBalance;

    function deposit() public payable {
         require(msg.value > 0,"add some funds");
         balances[msg.sender] += msg.value;
    }

    function getMyBalance() public view returns(uint){
        return balances[msg.sender];
    }

    function withdraw(uint amount) public payable{
        require(balances[msg.sender] >= amount ,"No Funds");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function getAllBalances() public view checkOwner returns(uint){
        return address(this).balance;
    }
}