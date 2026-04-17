// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IncreDecre{
     uint public value = 0;

     function Increment() public returns(uint){
        value++;
        return value;
     }

      function Decrement() public returns(uint){
        value--;
        return value;
     }
}