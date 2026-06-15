// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract loan_DeFi{
    struct Lender{
        address user;
        uint amount;
        uint interest;
        uint time;
    }
    mapping(address => Lender) public lenders;
    mapping(address => uint) public borrowers;

    struct FD{
        address user;
        uint amount;
        uint rewardAmount;
        uint timestamp;
    }

    mapping(address => FD) public FDs;
    uint totalFDs;

    uint public borrowAllowed;

    function addLending(uint _time) public payable{
        require(msg.value>= 5 ether,"Minimum 5 eth required to become lender");
        uint timeperiod = (block.timestamp + _time) - block.timestamp;
        uint interest = simpleInterest(msg.value, timeperiod);
        lenders[msg.sender] = Lender(msg.sender, msg.value, interest, timeperiod);
        
    }

    function borrow(uint256 _amount) public {
    uint256 poolBalance = address(this).balance;
    borrowAllowed = poolBalance / 2;

    require(_amount > 0, "Borrowing amount must be greater than zero");
    require(_amount <= borrowAllowed, "Cannot borrow more than 50% of pool");

    borrowers[msg.sender] +=  ((_amount * 10 ) /100) +_amount;

    (bool success, ) = msg.sender.call{value: _amount}("");
    require(success, "Failed to send Ether");
}

      function deposit_borrow_amount() public payable {
        require(msg.value>= 0,"deposit amount never be zero");
        require(borrowers[msg.sender] > 0,"Already Cleared");
        uint deposit_amount = ((borrowers[msg.sender] *10)/100) + borrowers[msg.sender] ;
        require(deposit_amount >= msg.value, "have to repay 10% more than borrowed amount");
        borrowers[msg.sender] -= msg.value;
    }

    function addFD(uint time) public payable{
        require(msg.value>=1 ether,"Minimum 1 ether required");
        totalFDs++;
        uint timelimit = block.timestamp + time;
        uint reward = msg.value + (((timelimit - block.timestamp)*1000000 gwei ) / 10);
        FDs[msg.sender] = FD (msg.sender, msg.value, reward,timelimit);
    }

    function withdraw_FD() public{
        require(FDs[msg.sender].rewardAmount > 0,"Already collected or Fd not started");
        require(FDs[msg.sender].timestamp <= block.timestamp,"Time left to withdraw FD");
        (bool success, ) = msg.sender.call{value: FDs[msg.sender].rewardAmount}("");
        require(success, "Failed to send Ether");
        delete FDs[msg.sender];
    }

    function simpleInterest(uint _principle, uint _time) internal pure returns(uint _interest){
        _interest = (_principle * 2 * (_time  / 10))/100;
        return _interest;
    }

    
}