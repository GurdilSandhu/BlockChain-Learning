// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MutliModifier{
    address owner;
    uint public amount;

    constructor(){
        owner=msg.sender;
    }

    modifier checkOwner{
       require(owner==msg.sender,"Not Owner");
       _;
    }

    modifier moneyTransfer(uint value){
       require(value>=100,"Amount should be greater than or equal to 100");
       _;
    }

    function number(uint value) public checkOwner{
          amount+=value;
    }

    function Transfer(uint value) public moneyTransfer(value){
          
          amount-=value;
    }
}