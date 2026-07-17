// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract counter{
    uint num;

    function incByOne() public{
        num++;
    }

    function incByValue(uint value) public{
        num += value;
    }

    function getNum() public view returns(uint){
        return num;
    }

    function reset() public{
        num = 0;
    }
}