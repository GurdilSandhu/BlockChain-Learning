// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MessageBoard {

    struct User {
        uint id;
        string userName;
        address userAddress;
    }

    struct Message {
        string userName;
        string message;
    }

    // Events
    event UserRegistered(
        uint indexed id,
        address indexed userAddress,
        string userName
    );

    event MessagePosted(
        address indexed userAddress,
        string userName,
        string message
    );

    uint public totalUsers;

    mapping(address => User) public userDetails;
    mapping(string => bool) public userNames;
    mapping(address => bool) public isExisted;

    Message[] private allMessages;

    function addUser(string memory _name) public {
        require(!isExisted[msg.sender], "Already Existed");

        checkAvailability(_name);

        totalUsers++;

        isExisted[msg.sender] = true;

        userDetails[msg.sender] = User(totalUsers,_name,msg.sender);

        emit UserRegistered(
            totalUsers,
            msg.sender,
            _name
        );
    }

    function checkAvailability( string memory _userName) private {
        require(!userNames[_userName],"Not Available");
        userNames[_userName] = true;
    }

    function addMessage( string memory _message ) public {
        require( isExisted[msg.sender], "Not Registered");
        allMessages.push(Message(userDetails[msg.sender].userName,_message));

        emit MessagePosted(
            msg.sender,
            userDetails[msg.sender].userName,
            _message
        );
    }

    function getMessage(uint index)
    public
    view
    returns(
        string memory,
        string memory
    )
{
    Message memory m = allMessages[index];

    return (
        m.userName,
        m.message
    );
}

function getTotalMessages()
    public
    view
    returns(uint)
{
    return allMessages.length;
}
}