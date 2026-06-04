// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract toDo{
    
    struct Task{
        uint id;
        string title;
        string description;
        address tasker;
        bool isComplete;
        bool isForfeit;
    }
     uint inProgressTasks;
     mapping(address => mapping(uint => Task)) public userTasks;
     mapping(address => uint256) public taskCounts;


    function addtask(string memory _title, string memory _description) public {
        uint taskId = taskCounts[msg.sender];
        userTasks[msg.sender][taskId]=Task(taskId,_title, _description, msg.sender, false, false);
        taskCounts[msg.sender]++;
        inProgressTasks++;
    }

    function completeTask(uint _taskId) public {
        require(_taskId < taskCounts[msg.sender], "Task does not exist");
        require(userTasks[msg.sender][_taskId].isComplete == false,"Already Completed");
        userTasks[msg.sender][_taskId].isComplete = true;
    }

    function forfeitTask(uint _taskId) public {
        require(_taskId < taskCounts[msg.sender], "Task does not exist");
        require(userTasks[msg.sender][_taskId].isComplete == false,"Already Completed");
        require(userTasks[msg.sender][_taskId].isForfeit == false,"Already Forfeited");
        userTasks[msg.sender][_taskId].isForfeit = true;
    }

    function getTaskCount() public view returns(uint){
      require(inProgressTasks>0,"No tasks found");
      return inProgressTasks;
    }

    function getTask(uint taskId)public view returns(Task memory){
        require(taskCounts[msg.sender]>0,"No tasks found");
        return userTasks[msg.sender][taskId];
    }

    function deleteTask(uint _taskId)public{
        require(userTasks[msg.sender][_taskId].isComplete || userTasks[msg.sender][_taskId].isForfeit ,"Task not completed");
        delete userTasks[msg.sender][_taskId];
        inProgressTasks--;
    }
}