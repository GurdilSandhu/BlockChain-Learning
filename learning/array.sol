// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Array{ 
   //   uint[][] public numbers;
   //   uint selected_index;

   //   constructor(uint initialSize) {
   //      for (uint i = 0; i < initialSize; i++) {
   //          numbers.push();
   //      }
   //   }

   //  function selectIndex(uint index) public{
   //    require(index < numbers.length, "Index out of bounds");
   //     selected_index = index;
   //  }

   //  function addNumber(uint value) public{
   //     require(numbers.length > 0, "No array selected yet");
   //       numbers[selected_index].push(value);
   //  }

   //   function getAll() public view returns(uint[][] memory){
   //      return numbers;
   //   } 



   uint[] public number;
   function addNumber(uint value) public{
      number.push(value);
   }

   function removeNumber() public{
      number.pop();
   }

   function total()public view returns(uint sum){
      for(uint i=0;i<number.length;i++){
         sum += number[i];
      }
      return sum;
   }

   function getAll() public view returns(uint[] memory){
      return number;
   }
}

