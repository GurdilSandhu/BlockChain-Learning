// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract crowdFunding{

        address owner;
        uint public goal;
        uint public totalFunds;
        uint deadline;

        event addingFunds(address indexed sender,uint amount);
        event remaining_time(uint time);
        event withdraw_funds(uint amount);
        event refund_funds(address receiver, uint amount); 


        constructor(uint _goal, uint _min){
            owner = msg.sender;
            goal = _goal;
            deadline = block.timestamp + _min * 1 minutes;
        }
       
        mapping (address => uint) public contributions;
        event startCrowdFunding(address Owner, uint goal);

        function addFunds() public payable {
            require(totalFunds <= goal,"Goal Reached");
            require(deadline >= block.timestamp,"Campaign is over");
            contributions[msg.sender] += msg.value;
            totalFunds += msg.value;

            emit addingFunds(msg.sender, msg.value);
        }

        function timeleft() public returns(uint){
            if(deadline > block.timestamp){
                emit remaining_time(deadline-block.timestamp);
               return (deadline-block.timestamp);
            }else{
                emit remaining_time(0);
            return 0;
            }
            
        } 

        function withdraw() public payable {
            require(msg.sender==owner,"Access Denied");
            require(goal <= totalFunds,"Goal not reached");
            emit withdraw_funds(address(this).balance);
            payable(owner).transfer(address(this).balance);
        }

        function refund() public payable{
            require(deadline < block.timestamp,"Campaign still active");
            uint amount = contributions[msg.sender];
            contributions[msg.sender]=0;
            payable(msg.sender).transfer(amount);
            totalFunds -= amount;

            emit refund_funds(msg.sender,amount);
        }
        
}