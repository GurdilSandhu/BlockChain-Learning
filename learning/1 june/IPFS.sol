// cid store in variable
// get file url


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IPFS{
    string cId;

    function addCid(string memory _cId)public {
        cId = _cId;
    }
    function geturl()public view returns(string memory){
        string memory mainURL = string(abi.encodePacked("https://ipfs.io/ipfs/",cId));
    
        return mainURL;
    }
}
