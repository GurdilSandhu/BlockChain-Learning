// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RoleControl {


    enum Role { Admin, Manager, User }

    mapping(address => Role) public roles;

    constructor(){
        roles[msg.sender]= Role.Admin;
    }

    modifier onlyAdmin() {
        require(roles[msg.sender]== Role.Admin,"Access Denied");
        _;
    }

    modifier onlyManager() {
        require(Role.Manager==roles[msg.sender],"Access Denied");
        _;
    }

    function assignRole(address _user, Role _role) public onlyAdmin{
        // only admin
        roles[_user]= _role;  

    }

    struct Task{
        uint id;
        string Description;
        bool isCompleted;
    }

    mapping (uint => Task) public tasks;
    uint[] alltaskIds;

    function createTask(uint _id, string memory _description) public onlyManager{
        // only manager
        alltaskIds.push(_id);
        tasks[_id] = Task(_id, _description, false);
    }

    function completeTask(uint _id ,bool _isCompleted) public {
        // only user
        tasks[_id] = Task(_id, tasks[_id].Description, _isCompleted);
    }
}