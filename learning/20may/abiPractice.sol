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

     

    function FLDOB_Combine(string memory _fName,string memory lName,uint DOB) public pure returns(string memory){
        return string(abi.encodePacked(_fName,lName,Strings.toString(DOB)));
    }

    function hashBoth(
        uint _num,
        string memory _word
    )
        public
        pure
        returns(bytes32)
    {    
        //0x0a0e9ab94d02b5337561d85c048707c3111b707cfc6e9f6063953a97639c67a4
        //0x3277411ad36d533d3789b37c652a5387b38c29322704fa30f36fad9bfc05bf3a
        return keccak256(abi.encodePacked(_word,_num));
}
function generateStudentId(string memory sName,uint roll)public pure returns(bytes32){

        return keccak256(abi.encodePacked(roll,sName));
    }
    function generateHash(string memory name)public view returns(bytes32){

        return keccak256(abi.encodePacked(name, block.timestamp, msg.sender));
    }
}