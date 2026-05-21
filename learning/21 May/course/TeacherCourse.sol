// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TeacherCourse {

    address public teacher;

    constructor() {
        teacher = msg.sender;
    }

    struct Course {
        string courseName;
        uint duration;
        uint fee;
        bool exists;
    }

    Course public course;

    modifier onlyTeacher() {
        require(msg.sender == teacher, "Not teacher");
        _;
    }

    function createCourse(
        string memory _name,
        uint _duration,
        uint _fee
    ) public onlyTeacher {
        require(!course.exists, "Course already created");

        course = Course(_name, _duration, _fee, true);
    }

    function updateCourse(
        string memory _name,
        uint _duration,
        uint _fee
    ) public onlyTeacher {
        require(course.exists, "Course not found");

        course.courseName = _name;
        course.duration = _duration;
        course.fee = _fee;
    }

    function getCourse() public view returns (string memory, uint, uint) {
        require(course.exists, "Course not found");
        return (course.courseName, course.duration, course.fee);
    }
}