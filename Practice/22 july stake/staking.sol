// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract staking{
    using SafeERC20 for IERC20;

    IERC20 public token;
    address public owner;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

   modifier onlyOwner() {
        require(msg.sender == owner, "Access Denied");
        _;
    }

   struct User{
    address wallet;
    uint deposit;
    uint staked;
    uint time;
    uint timepassed;
   }
   uint public totalUsers;
   mapping(address => User) public users;

   function depositToken(uint amount) public{
    totalUsers++;
    users[msg.sender] = User(msg.sender,amount,0,block.timestamp,0);
    token.safeTransferFrom(msg.sender, address(this), amount);
   }

   function checkAccount()public view returns(address, uint, uint, uint,uint){
    User memory p = users[msg.sender];
    uint inc = (block.timestamp-p.time)/60; 
      p.staked = inc;
      return(p.wallet,p.deposit,p.staked,p.time,block.timestamp-p.time);
   }

    function withdrawToken() public{
    User memory p = users[msg.sender];
    uint inc = (block.timestamp-p.time)/60; 
      p.staked = inc;
      uint totalTokens= p.deposit+inc;
    token.safeTransferFrom(owner,msg.sender, totalTokens);
   }

}