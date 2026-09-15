// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract GuestBook {

    // Stores information about each guest
    struct Guest {
        address wallet;
        string name;
        uint256 timestamp;
    }

    // Array containing all registered guests
    Guest[] private guests;

    // Keeps track of wallets that have already registered
    mapping(address => bool) public hasRegistered;

    // Event emitted whenever a new guest registers
    event GuestRegistered(
        address indexed wallet,
        string name,
        uint256 timestamp
    );

    // Register a guest
    function register(string calldata _name) external {

        // Prevent the same wallet from registering more than once
        require(
            !hasRegistered[msg.sender],
            "Wallet already registered"
        );

        // Make sure the name is not empty
        require(
            bytes(_name).length > 0,
            "Name cannot be empty"
        );

        // Store guest information
        guests.push(
            Guest({
                wallet: msg.sender,
                name: _name,
                timestamp: block.timestamp
            })
        );

        // Mark this wallet as registered
        hasRegistered[msg.sender] = true;

        // Emit registration event
        emit GuestRegistered(
            msg.sender,
            _name,
            block.timestamp
        );
    }

    // Get all registered guests
    function getAllGuests()
        external
        view
        returns (Guest[] memory)
    {
        return guests;
    }

    // Get the total number of registered guests
    function getGuestCount()
        external
        view
        returns (uint256)
    {
        return guests.length;
    }
}