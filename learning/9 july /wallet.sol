// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract wallet{
    
    struct User{
        address wallet;
        uint balance;
    }
    
    mapping(address => User) public users;

    function deposit(address _userAddress) external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        users[_userAddress] = User({
            wallet : msg.sender,
            balance : users[msg.sender].balance + msg.value
        });
    }

    function getBalance(address _userAddress) external view returns(uint _balance) {
        return users[_userAddress].balance;
    }

    function transfer(address _userAddress,address _wallet,uint _amount)external {
        require(_amount > 0, "Transfer amount must be greater than 0");
        require(users[_userAddress].balance >= _amount, "Insufficient balance");
        users[_userAddress].balance -= _amount;
        users[_wallet] =User(_wallet, users[_wallet].balance + _amount);
       payable(_wallet).transfer(_amount);
    }
}