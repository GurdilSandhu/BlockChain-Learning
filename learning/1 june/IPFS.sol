// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IPFS{
    string CID;
 
    function addCid(string memory _CID)public{
        CID = _CID;
    }
    function geturl()public view returns(string memory){
        string memory mainURL = string(abi.encodePacked("https://ipfs.io/ipfs/",CID));
    
        return mainURL;
    }
}
