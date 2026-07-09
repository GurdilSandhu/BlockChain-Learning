// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface Iwallet{
    function deposit(address _userAddress) external payable;
    function getBalance(address _userAddress)external view returns(uint _balance);
    function transfer(address _userAdress,address _wallet,uint _amount)external;
}

contract wallet_application{
    Iwallet public app;

    constructor(address walletAddress){
        app = Iwallet(walletAddress);
    }

    function deposit() public payable{
       app.deposit{value: msg.value}(msg.sender);
    }

    function getBalance() public view returns(uint balance){
        balance = app.getBalance(msg.sender);
    }

    function transfer(address receiver, uint amount) public{
        app.transfer(msg.sender,receiver, amount);
    }
}