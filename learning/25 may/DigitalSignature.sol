// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DigitalSignature {
    
    bytes32 message;
    // Create hash of message
    function getMessageHash(string memory _message) public returns(bytes32) {
        message = keccak256(abi.encodePacked(_message));
        return message;
    }

     bytes32 ethMessage;
    // Ethereum signed message hash
    function getEthSignedMessageHash() public returns(bytes32) {
        ethMessage = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",message));
        return ethMessage;
    }

}