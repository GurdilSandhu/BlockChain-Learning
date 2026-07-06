// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract WalletDemo {
    struct Keys {
        bytes32 privateKey;
        address publicKey;
    }

    function generateKeys() public view returns (address, bytes32) {
        bytes32 privateKey = keccak256(
            abi.encodePacked(
                block.timestamp,
                block.prevrandao,
                msg.sender,
                gasleft()
            )
        );

        address publicKey = address(
            uint160(uint256(keccak256(abi.encodePacked(privateKey))))
        );

        return (publicKey, privateKey);
    }
}
