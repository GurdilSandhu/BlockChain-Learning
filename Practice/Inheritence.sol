// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//single Inheritence

// contract Student{
//     string name;
//     uint age;

//     function details(string memory _name, uint _age) public{
//           name= _name;
//           age= _age;
//     }
// }

// contract Result is Student{
//     uint marks;

//     function Marks(uint _marks) public{
//         marks = _marks;
//         //details("Sam", 19);

//     }

//     function getAll() public view returns(string memory, uint, uint){
//          return(name,age,marks);
//     }
// }

contract father{
    uint number_of_rooms;
    string houseName;

    function houseDetails(string memory _name, uint _number_of_rooms) public{
         houseName = _name;
         number_of_rooms = _number_of_rooms;
    }
}

contract mother{
    uint amount;

    function jewelry(uint _amount) public{
         amount = _amount;
    }
}

contract child is father, mother{
    string studentName;

    function StudentName(string memory _name) public{
         studentName = _name;
    }

    function getDetails() public view returns(string memory, string memory, uint, uint){
         return(studentName,houseName, number_of_rooms,amount);
    }
}