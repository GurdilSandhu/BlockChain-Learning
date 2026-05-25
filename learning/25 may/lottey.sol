// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LotteryWinner{
   //winner will be 1-10
    function findWinner()public view returns(uint){
        uint winner = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp))) % 10 + 1;

        return winner;
    }

    function hash_nums(uint num1, uint num2, uint num3)public pure returns(bytes32){
        return keccak256(abi.encodePacked(num1,num2,num3));
    }

    string name;

    function enter_name(string memory _name)public{
        name = _name;
    }

    function check_name(string memory _name)public view returns(bool){
        if(keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked(_name))){
        return true;
        }
        return false;
    }

    mapping (string => bool) public userNames;
    
    function registerUserName(string memory _userName)public{
       require(userNames[_userName]==false,"Not Available");
       userNames[_userName] = true;
    }

    function checkAvailability(string memory _userName)public view returns(bool){
        if(userNames[_userName] == true){
        return false;
        }
        return true;
    }
}