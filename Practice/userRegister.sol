// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract userRegister{
    mapping(address=> string) public accounts;

    event registerUser(address account, string name);

    function addUser(string memory _name) public {
        accounts[msg.sender] = _name;
        emit registerUser(msg.sender, _name);
    }

}