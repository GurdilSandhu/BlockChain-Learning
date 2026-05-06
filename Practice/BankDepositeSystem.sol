// 4. Bank Deposit System

// Requirements:

// Mapping for balances (address => uint)
// Array to store all users who deposited
// Function to deposit:
// Use require to ensure deposit > 0
// Add user to array if first-time deposit
// Function to withdraw:
// Use require to check sufficient balance

// Expected Output:

// Tracks balances correctly
// Prevents zero deposits
// Prevents over-withdrawal

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
contract Bank_Deposite_System {
    mapping(address => uint) balance;
    address[] users;
    mapping(address => bool) isUserAdded;

    function Deposit(uint amount) public {
        require(amount > 0, "amount should be greater than 0");
        balance[msg.sender] += amount;
        if (!isUserAdded[msg.sender]) {
            users.push(msg.sender);
            isUserAdded[msg.sender] = true;
        }
    }

    function Withdraw(uint amount) public {
        require(
            amount > 0 && amount < balance[msg.sender],
            "amount should be greater than 0 and must be in bank"
        );
        balance[msg.sender] -= amount;
    }

    function getAllUsers() public view returns (address[] memory, uint[] memory) {
        uint[] memory all_balances=new uint[](users.length);
        for (uint i = 0; i < users.length; i++) {
            all_balances[i]= balance[users[i]];
        }

        return (users, all_balances);
    }

     function checkBalance() public view returns(uint){
        return balance[msg.sender];
    }
}
