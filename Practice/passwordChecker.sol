// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract passwordChecker{
    string private password = "gurdil";

    function checkPassword(string memory input) public view returns(string memory){
        if(keccak256(bytes(input))==keccak256(bytes(password))){
           return "Access Granted";
        }
        return "Access Denied";
    }

    function password_in_bytes(string memory _input) public pure returns(bytes memory){
        return bytes(_input);
    }

    
    function password_length(string memory _input) public pure returns(uint){
        uint strLength = bytes(_input).length;
        return strLength;
    }

    function getFirstByte(string memory _input) public pure returns(bytes1){
        bytes memory Bytes = bytes(_input);
        bytes1 firstByte = Bytes[5];
        return firstByte;
    }

    function bytestoString(bytes memory _input) public pure returns(string memory){
        return string(_input);
    }

    function concat()public pure returns(bytes memory){
       bytes memory a = "Hello"; 
       bytes memory b = "World!";
       return  abi.encodePacked(a,b);

    }

    function toUppercase(string memory _input) public pure returns(string memory){
        bytes memory strByte = bytes(_input);
        uint strLength = strByte.length;
        bytes memory resStr= new bytes(strLength);

        for(uint i=0;i<strLength;i++){
            if(uint8(strByte[i])>=97 && uint8(strByte[i])<=122){
              resStr[i] = bytes1(uint8(strByte[i])-32);
            }else{
            resStr[i] = strByte[i];
        }
        }

        return string(resStr);
    }

    function toLowercase(string memory _input) public pure returns(string memory){
        bytes memory strByte = bytes(_input);
        uint strLength = strByte.length;
        bytes memory resStr= new bytes(strLength);

        for(uint i=0;i<strLength;i++){
            if(uint8(strByte[i])>=65 && uint8(strByte[i])<=90){
              resStr[i] = bytes1(uint8(strByte[i])+32);
            }else{
            resStr[i] = strByte[i];
        }
        }

        return string(resStr);
    }

    function countWords(string memory _input) public pure returns(uint){
        bytes memory bStr = bytes(_input);
        uint strLength = bStr.length;

        if (strLength == 0) {
            return 0;
        }

        uint count = 0;
        bool inWord = false;

        for (uint i = 0; i < strLength; i++) {
            if (bStr[i] != 0x20 && !inWord) {
                inWord = true;
                count++;
            } else if (bStr[i] == 0x20) {
                inWord = false;
            }
    }
    return count;
}

function compareString(string memory a, string memory b) public pure returns(bool){
    bytes memory bStr1 = bytes(a);
    bytes memory bStr2 = bytes(b);
    uint strLength1 = bStr1.length;
    uint strLength2 = bStr2.length;
        if (strLength1 != strLength2) {
            return false;
        }

        for (uint i = 0; i < strLength1; i++) {
            if (bStr1[i] != bStr2[i]) {
                return false;
            }
    }
    return true;
}

function reverseString(string memory input) public pure returns(string memory){
    bytes memory bStr = bytes(input);
    bytes memory rStr = new bytes(bStr.length);

    for(uint i=0;i<bStr.length;i++){
        rStr[i] = bStr[bStr.length-1-i];
    }
    return string(rStr);
}
}