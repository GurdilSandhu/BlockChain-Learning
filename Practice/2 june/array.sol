// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract array{
    uint[] arr = [1,2,3,4,4,5,6,7];
    uint[]  arr1;

    function findLargest()public view returns(uint result){
        result = arr[0];
        for(uint i=1;i<arr.length;i++){
            if(arr[i]>result){
                result=arr[i];
            }
        }
        return result;
    }

    function findSum()public view returns(uint result){
        for(uint i=0;i<arr.length;i++){
                result+=arr[i];
        }
        return result;
    }

    function countDigits(uint number)public pure returns(uint result){

        while(number!=0){
            number /= 10;
            result++;
        }
        return result;
    }
    
    function addNumber(uint _value) public {
        arr1.push(_value); 
    }

     function removeDuplicates() public {
        uint n = arr1.length;
        uint uniqueCount = 0;
        
        for (uint i = 0; i < n; i++) {
            bool isDuplicate = false;
            for (uint j = 0; j < uniqueCount; j++) {
                if (arr1[i] == arr1[j]) {
                    isDuplicate = true;
                    break;
                }
            }
            if (!isDuplicate) {
                arr1[uniqueCount] = arr1[i];
                uniqueCount++;
            }
        }
        uint elementsToRemove = n - uniqueCount;
        for (uint i = 0; i < elementsToRemove; i++) {
            arr1.pop();
        }
     }

      function getArray() public view returns (uint[] memory) {
        return arr1;
    }
}