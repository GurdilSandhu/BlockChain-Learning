// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Hashing{

    mapping(address => bytes32) public coupons;
    mapping(address => bool) public isCouponGenerated;
    function generateCouponHash() public returns(bytes32){
        require(isCouponGenerated[msg.sender] == false, "Already Generated");
           coupons[msg.sender] = keccak256(abi.encodePacked(msg.sender, block.timestamp));
           isCouponGenerated[msg.sender]= true;
           return keccak256(abi.encodePacked(msg.sender, block.timestamp));
    }

    mapping(string => bytes32) public attendence;
    mapping(string => bool) public isAttendenceMarked;
    function studentAttendence(string memory name, string memory className) public {
        require(isAttendenceMarked[name]==false,"Already Marked");
        attendence[name] = keccak256(abi.encodePacked(name,block.timestamp,className));
        isAttendenceMarked[name] = true;
    }

}