// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract flight_delay{
    address owner;
    uint flightTime;
    constructor(uint _flightTime){
        owner = msg.sender;
        flightTime = block.timestamp + _flightTime;
    }
    struct flight{
       address user;
       uint time;
       uint amount;
    }
    mapping(uint => flight) public flights;
    uint userIds;
    function buyTicket() public payable{
        require(msg.value == 100 wei,"ticket price is 100 wei");
        userIds++;
        flights[userIds] = flight(msg.sender,flightTime, msg.value);
    }

    function cancel() public{
        require(msg.sender == owner,"Access Denied");
          require(block.timestamp > flightTime, "canceled");
          for(uint i=1;i<=userIds;i++){
          payable(flights[i].user).transfer(100 wei);
          }
    }

    function badService_delay() public{
        require(msg.sender == owner,"Access Denied");
          require(block.timestamp > flightTime, "dealyed");
          for(uint i=1;i<=userIds;i++){
          payable(flights[i].user).transfer(10 wei);
          }
    }
}