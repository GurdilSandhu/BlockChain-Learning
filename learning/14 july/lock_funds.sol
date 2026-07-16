// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract lock_funds{
    uint public deployNumber;
    uint unlock_Number;
    constructor(){
        deployNumber = block.number;
        unlock_Number = deployNumber+20;
    }

    function addfunds()public payable{
    }
    
    function currentBlock()public view returns(uint){
        return block.number;
    }
    function withdraw() public{
        require(unlock_Number<=block.number,"still locked");
        payable(msg.sender).transfer(address(this).balance);
    }
}