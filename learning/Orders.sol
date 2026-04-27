// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Orders{

    address owner;

    constructor(){
        owner=msg.sender;
    }

    modifier checkOwner{
        require(owner==msg.sender,"Access Denied");
        _;
    }

    enum Status{Pending,Prepared,Shipped,Delivered,Cancelled}
 
    struct Order{
        uint id;
        string deliveryPartner;
        Status status;
    }
    
    mapping (uint => Order) public orders;
    mapping (uint => bool) isOrdered;

    struct User{
        uint id;
        string name;
        address wallet;
    }
    
    mapping (uint => User) public users;
    mapping (address => bool) isRegistered;
    uint[] allUserIds;

    function addUser(uint _id, string memory name) public {
         require(!isRegistered[msg.sender],"user already registered");
           allUserIds.push(_id);
           users[_id] = User(_id,name,msg.sender);
           isRegistered[msg.sender] = true;
    }


    function addOrder(uint _id, string memory deliveryPartner) public{
         orders[_id] = Order(_id, deliveryPartner,Status.Pending);
    }

    function updateOrder(uint _id, Status _status) public checkOwner{
         orders[_id]= Order(_id, orders[_id].deliveryPartner, _status);
    }

}