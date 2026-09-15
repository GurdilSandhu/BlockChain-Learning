// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TP{
    uint public balance;

    function add_money(uint amount) public {
        balance+= amount;
    }

    function get_balance() public view returns (uint){
        return balance;
    }
}
