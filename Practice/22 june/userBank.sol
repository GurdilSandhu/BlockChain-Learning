// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract UserBank {
    // event Depo (address indexed Owner, uint _amount);
    address owner;
    struct userDetail {
        address id;
        uint balance;
    }

    uint totalUsers;
    mapping(address => userDetail) details;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function deposit(address user) external payable {
        require(msg.value > 2000, "Add Some Money");
        if (details[user].id == address(0)) {
            totalUsers++;
            details[user].id = user;
        }
        details[user].id = user;
        details[user].balance += msg.value;

        // emit Depo(msg.sender,amount);
    }

    function withdraw_cash(address user, uint amount) external {
        require(details[user].balance > 2000, "not enough balance");
        require(amount < (details[user].balance - 2000), "not enough balance");
        require(details[user].balance >= amount + 2000);

        details[user].balance -= amount;
        payable(user).transfer(amount);

        // emit Depo(msg.sender,amount);
    }
    function Get_Balance(address user) external view returns (uint) {
        uint balance = details[user].balance;
        return balance;
    }
}
