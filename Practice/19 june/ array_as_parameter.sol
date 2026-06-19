// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommunityWallet {
    address[] public owners;

    constructor(address[] memory _initialOwners) {
        require(_initialOwners.length > 0, "Must provide at least one owner");
        owners = _initialOwners;
    }
}
