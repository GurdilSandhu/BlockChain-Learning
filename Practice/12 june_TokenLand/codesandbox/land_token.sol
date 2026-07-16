// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract block_passed{
    uint public deployNumber;
    constructor(){
        deployNumber = block.number;
    }

    function blockPassed()public view returns(uint count)
    {
        return (block.number - deployNumber);
    }
}