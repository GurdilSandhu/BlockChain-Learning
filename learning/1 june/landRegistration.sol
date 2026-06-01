// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract landRegistration{
    struct Land{
        uint landNumber;
        uint landSize;
        string landUrl ;
        uint landPrice; 
        address owner;
    }
    
    mapping(uint => Land) public lands;
    mapping(address => bool) public isOwned;
    function addOwner(uint _landNumber, uint _landSize, string memory _landCid, uint _landPrice, address _owner) public{
         require(!isOwned[lands[_landNumber].owner], "Owner already exists");
         lands[_landNumber] = Land(_landNumber, _landSize, string(abi.encodePacked("https://ipfs.io/ipfs/",_landCid)), _landPrice, _owner);
         isOwned[lands[_landNumber].owner] = true;
    }

    function transferOwnership(uint _landNumber, address _newOwner) public payable{
        require(isOwned[lands[_landNumber].owner], "Owner does not exist");
        require(lands[_landNumber].owner != _newOwner, "Does not sell to same owner");
        require(msg.value == lands[_landNumber].landPrice, "Insufficient funds");
        isOwned[lands[_landNumber].owner] = false;
        lands[_landNumber].owner = _newOwner;
        isOwned[lands[_landNumber].owner] = true;
    }
    
    function getLandDetails(uint _landNumber) public view returns (uint, uint, string memory, uint, address){
        return (lands[_landNumber].landNumber, lands[_landNumber].landSize, lands[_landNumber].landUrl, lands[_landNumber].landPrice, lands[_landNumber].owner);
    }



}