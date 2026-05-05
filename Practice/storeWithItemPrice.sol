// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleStore{
    address owner;

    constructor(){
        owner = msg.sender;
    }

    event ProductBought(address buyer, uint amount);

    function buy() public payable {
        require(msg.value==1 ether,"value not matched");
        payable(address(this)).transfer(msg.value);

        emit ProductBought(msg.sender, msg.value);
    }
}