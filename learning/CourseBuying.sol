// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./CourseSelling.sol";


contract CourseBuying{
    CourseSelling purchase;

    constructor(address linkaddress){
        purchase = CourseSelling(linkaddress);
    }

    function addStudent(uint id, string memory name, uint demandfees) public{
          purchase.addStudent(id, name, demandfees);
    }
}  