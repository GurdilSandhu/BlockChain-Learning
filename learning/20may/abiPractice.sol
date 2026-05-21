// SPDX-License-Identifier: MIT
pragma solidity ^0.8.31;

import "@openzeppelin/contracts/utils/Strings.sol";

contract abiPrac{

    // function uintToString(uint value)internal pure returns(string memory){
    //     if(value == 0){
    //         return "0";
    //     }

    //     uint temp = value;
    //     uint digits;

    //     // count digits
    //     while(temp != 0){
    //         digits++;
    //         temp /= 10;
    //     }

    //     bytes memory buffer = new bytes(digits);

    //     while(value != 0){
    //         digits -= 1;
    //         buffer[digits] = bytes1(
    //             uint8(48 + value % 10)
    //         );
    //         value /= 10;
    //     }

    //     return string(buffer);
    // }

    bytes32 public generatedHash;

    function fullname(string memory _fName, string memory mName,string memory lName) public pure returns(string memory){
        return string(abi.encodePacked(_fName," ",mName , " ",lName));
    }
    function hashGenerator(address sender,address reciever)public payable{

        generatedHash = keccak256(abi.encodePacked(sender,reciever,Strings.toString(msg.value)));
    }

    function greet(string memory fName)public pure returns(string memory){
        return string(abi.encodePacked("Hello"," ",fName));
    }

    function combine_City_Country(string memory city, string memory country)public pure returns(string memory){
        return string(abi.encodePacked("City: ",city," "," Country: ",country));
    }

    function generateStudentId(string memory sName,uint roll)public pure returns(bytes32){

        return keccak256(abi.encodePacked(Strings.toString(roll),sName));
    }

     

    function FLDOB_Combine(string memory _fName,string memory lName,uint DOB) public pure returns(string memory){
        return string(abi.encodePacked(_fName,lName,Strings.toString(DOB)));
    }

}