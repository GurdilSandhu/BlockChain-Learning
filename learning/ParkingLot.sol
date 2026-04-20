// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Parking{
    uint public Total_slots=100;

    function book(uint slots) public{
        require(Total_slots>0,"Not sufficient slots");
        
        Total_slots-=slots;

    }

    function leave(uint slots) public{
        if(slots<=0){
          revert("Not booked");
        }
        Total_slots+=slots;

        assert(Total_slots<=100);
    }
}