// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract array{
    uint[] smArr;
     uint[] arr1 = [2,3,4,5,6,7];
     uint[] arr2 = [11,2,4,55,6,6,77,8];
     uint[] uniqueResult;

     function array_with_same_value(uint value, uint length) public{
           for(uint i=0;i<length;i++){
            smArr[i] = value;
           }
     }

     function get_smArr() public view returns(uint[] memory){
          return smArr;
     }

     mapping(uint => bool) unique;

     function merge() public view returns(uint[] memory){
        uint size = arr1.length + arr2.length;
        uint[] memory res = new uint[](size);

        for(uint i=0;i<arr1.length;i++){
            res[i] = arr1[i];
        }

        for(uint j=0;j<arr2.length;j++){
            res[arr1.length+j] = arr2[j];
        }

        return res;
     }

     function onlyUnique() public{
             uint size = arr1.length + arr2.length;
        uint[] memory tempres = new uint[](size);
        uint count;

        for(uint i=0;i<arr1.length;i++){
            uint value = arr1[i];
            if(!unique[value]){
                tempres[count] = value;
                count++;
            unique[value]=true;
            }
        }

        for(uint i = 0;i<arr2.length;i++){
            uint value = arr2[i];
            if(!unique[value]){
            tempres[count] = value;
            count++;
            unique[value] =true;
        }
        }
        uint[] memory res = new uint[](count);
        for(uint i=0;i<count;i++){
            res[i] = tempres[i];
        }
        uniqueResult = res;
     }

     function get_uniqueArr() public view returns(uint[] memory){
          return uniqueResult;
     }
}