// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Student_MNG{
    struct Student{
        uint id;
        string name;
        uint marks;
    }
    
    mapping(uint => Student) students;
    uint[] allStudentIds;

    function addStudent(uint id, string memory name, uint marks) public {
        students[id] = Student(id,name,marks);
        allStudentIds.push(id);
    }

    function updateMarks(uint id, uint marks) public {
        students[id] = Student(id, students[id].name, marks);
    }

    function getStudent(uint id) public view returns(uint,string memory, uint){
         Student memory s = students[id];
         return(s.id,s.name,s.marks);
    }
}