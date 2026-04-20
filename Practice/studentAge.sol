// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StudentAge{
    
    uint age;

    function setAge(uint value) public returns(uint){
        age = value;
        return age;
    }

    function increaseAge(uint value) public returns(uint){
        age += value;
        return age;
    }

    function getAge() public view returns(uint){
        return age;
    }

    function resetAge() public returns(uint){
        age = 0;
        return age;
    }
}