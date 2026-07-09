// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface calc{

    function add(uint a, uint b)external pure returns(uint);
    function sub(uint a, uint b)external pure returns(uint);
    function multiply(uint a, uint b)external pure returns(uint);
    function divide(uint a, uint b)external pure returns(uint);
}

contract calculator{
     calc public cal;

    constructor(address interface_address) {
        cal = calc(interface_address);
    }

    function add(uint a, uint b) public view returns(uint result){
        return cal.add(a, b);
    }
    function sub(uint a, uint b) public view returns(uint result){
        return cal.sub(a, b);
    }
    function multiply(uint a, uint b) public view returns(uint result){
        return cal.multiply(a, b);
    }
    function divide(uint a, uint b) public view returns(uint result){
        return cal.divide(a, b);
    }
}
