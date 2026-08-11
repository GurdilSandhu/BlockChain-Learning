//SPDX-License-Indentifier: MIT
pragma solidity ^0.8.0;
/*
   Below code is how we declare interface in contracts but this is not the only way to use
   Interface we can also make another contract for interface only and that is the best practice
   and here you can see clearly that we only add functions with no body so this is what we called abstraction.
*/
interface IUserBank {
   function deposit(uint amount) external;
   function withdraw(uint amount) external;
   function checkBalance() external view returns(uint);
}

contract Userbank{
   IUserBank bank;
 /*
   Here inside the constructor when we are going to deploy before that we have to add 
   Contract address of contract from where we take the interface doing so we can use the logics of 
   functions we add inside interface above basically At this address, there is a contract that I want to communicate with using the IUserBank interface
*/
   constructor(address bankAddress){
   bank = IUserBank(bankAddress);
}

function depositAmount(uint  _amount) public{
    bank.deposit(_amount);   //this will change the state of that contract
}

function withdrawAmount(uint  _amount) public{
    bank.withdraw(_amount);   //this will change the state of that contract
}

function checkBalance() public view returns(uint Balance){
   Balance = bank.checkBalance();
    return Balance;  
}
}