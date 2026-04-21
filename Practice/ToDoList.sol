// 3. Todo List Smart Contract

// Requirements:

// Array to store tasks (string)
// Mapping to track task completion (index => bool)
// Function to add task
// Function to mark task complete:
// Use require to check valid index

// Expected Output:

// Tasks added in array
// Only valid tasks can be marked complete
// Completion status stored properly

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ToDo{
    string[] tasks;
    mapping(uint => bool) isComplete;

    function addTask(string memory task) public{
        require(bytes(task).length>=3,"Minimum 3 letter word");
        tasks.push(task);
    }

    function TickTask(uint index) public{
        require(!isComplete[index],"Already Completed");
        require(tasks.length>index,"Invalid task");
        
        isComplete[index]= true;
    }

    function getAllTasks() public view returns (string[] memory, bool[] memory) {
        bool[] memory completionStatus = new bool[](tasks.length);
        for (uint i = 0; i < tasks.length; i++) {
            completionStatus[i] = isComplete[i];
        }
        return (tasks, completionStatus);
    }

}