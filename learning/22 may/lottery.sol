// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract lottery{
    address owner;

    constructor(){
        owner = msg.sender;
    }

    struct Participants{
        uint id;
        address user;
        uint amount;
        bool winner;
    }

    
}