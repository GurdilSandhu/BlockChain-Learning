// Student Registration and Performance Tracker

// Problem Statement:
// Create a smart contract where each user can register themselves as a student using their wallet address. 
//Store student details such as name and marks using a structured data type. 
//The system should automatically determine whether the student has passed or failed based on their marks. 
//Ensure that a student can register only once and can update their marks later. 
//Only registered students should be able to view or delete their data. 
//Proper validation must be applied to restrict invalid marks and prevent unauthorized actions.
//Updat, Delete, add student and get all student 

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Student_Mark_Management{
    
    address owner;
    constructor(){
        owner=msg.sender;
    }
    modifier checkOwner{
        require(owner==msg.sender,"Access Denied");
        _;
    }


    struct student{
        uint id;
        string name;
        uint marks;
        bool ispassed;
        address wallet;
    }

    mapping (uint => student) public students;
    mapping (uint => bool) isExist;
    mapping(address => bool) hasRegistered;

    uint[] public allIds;

    function addStudent(uint id, string memory name, uint marks) public{
         require(!hasRegistered[msg.sender],"Student already exists");
         require(!isExist[id],"Student already exists");
         require(marks>=0 && marks<=100,"marks can be below 100 and above 0");
         bool passed = (marks>=34);
         allIds.push(id);
         hasRegistered[msg.sender]= true;
         isExist[id]=true;
         students[id] = student(id,name,marks,passed,msg.sender);
    }

     function updateStudentMarks(uint id,uint marks) public checkOwner{
         require(isExist[id],"Student doest not exist");
          bool passed = (marks>=34);
         students[id] = student(id,students[id].name,marks,passed,students[id].wallet);
    }

    function deleteStudent(uint id) public{
         require(isExist[id],"Student not found");
         delete students[id];
         isExist[id] = false;
         hasRegistered[msg.sender]=false;

         uint index;
         bool found;

         for(uint i=0;i<allIds.length;i++){
            if(allIds[id]==id){
                index=i;
                found=true;
                break;
            }
            if(found){
                allIds[index] = allIds[allIds.length-1];
                allIds.pop();
            }
         }

    }

    function getAllStudents() public view returns(student[] memory){
        student[] memory accessStudents = new student[](allIds.length);
        for(uint i=0;i<allIds.length;i++){
            accessStudents[i] = students[allIds[i]];
        }
        return accessStudents;
    }


}