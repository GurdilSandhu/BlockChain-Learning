//  Controlled User Registration with Capacity Limit

// Problem Statement:
// Create a contract where users can register themselves, 
//but only up to a fixed maximum limit defined during deployment. 
//Store all registered users in a list and track their registration status. 
//Ensure a user cannot register more than once. Only valid registrations should be accepted, 
//and once the limit is reached, no further entries should be allowed.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Registration_Management{
    mapping (uint => string) registrations;
    mapping (uint => bool) isRegistered;
    uint[] Total_Reg;

    modifier checkTotalRegistrations{
        require(Total_Reg.length<10,"Entries are Full now");
        _;
    }
    
    function addUser(uint id, string memory name) public checkTotalRegistrations{
       require(!isRegistered[id],"user already registered");
       Total_Reg.push(id);
       registrations[id]= name;
       isRegistered[id]=true;
    }

    function getFullDetails() public view returns (uint[] memory, string[] memory) {
        string[] memory all_users=new string[](Total_Reg.length);
        for (uint i = 0; i < Total_Reg.length; i++) {
            all_users[i]= registrations[Total_Reg[i]];
        }

        return (Total_Reg, all_users);
    }
}