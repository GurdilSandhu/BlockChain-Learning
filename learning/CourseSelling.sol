// teacher can add course duration fee
// import link send to student
// add student names
// student can add offer price

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CourseSelling {
    address owner;
    constructor() {
        owner = msg.sender;
    }
    modifier checkOwner() {
        require(owner == msg.sender, "Access Denied");
        _;
    }

    struct course {
        string courseName;
        string courseDuration;
        uint fees;
    }
    mapping(uint => course) public courses;
    uint[] allCourseIds;

    function addCourse(
        uint id,
        string memory name,
        string memory duration,
        uint fees
    ) external checkOwner {
        allCourseIds.push(id);
        courses[id] = course(name, duration, fees);
    }

    struct student {
        uint id;
        string studentName;
        uint demandFees;
        address wallet;
    }

    mapping(uint => student) public students;
    uint[] allStudentsIds;

    function addStudent(
        uint id,
        string memory name,
        uint demandfees
    ) external returns (uint) {
        allStudentsIds.push(id);
        students[id] = student(id, name, demandfees, msg.sender);
        return courses[id].fees;
    }
}
