// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract addArray{
    uint[] public num = [1,2,3];

    function addElement(uint value) public{
        num.push(value);
    }

     function getAll() public view returns(uint[] memory){
        return num;
     } 
}  