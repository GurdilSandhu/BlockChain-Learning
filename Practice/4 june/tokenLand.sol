// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenLand {

    struct Land {
        uint landNumber;
        string name;
        uint totalTokens;
        uint availableTokens;
        uint tokenPrice; 
        address owner;
    }

    struct landOwnership{
        uint totalTokens;
        uint ownershipPercentage;
    }

    mapping(uint => Land) public lands;
    mapping(uint => bool) public isExist;
    mapping(uint => mapping(address => landOwnership)) public tokenBalances;

    function tokenizeLand(uint _landNumber,string memory _name, uint _totalTokens,uint _landPrice) public {

        require(!isExist[_landNumber],"Land already tokenized");
        require(_totalTokens > 0,"Invalid token amount");
        require(_landPrice > 0,"Invalid land price");

        uint tokenPrice =(_landPrice * 1 ether) / _totalTokens;

        lands[_landNumber] = Land({
            landNumber: _landNumber,
            name: _name,
            totalTokens: _totalTokens,
            availableTokens: _totalTokens,
            tokenPrice: tokenPrice,
            owner: msg.sender
        });

        isExist[_landNumber] = true;
    }

    function buyToken(uint _landNumber,uint _tokenAmount) public payable {

        require(isExist[_landNumber],"Land not tokenized");
        require(_tokenAmount > 0,"Invalid token amount");

        Land storage land = lands[_landNumber];

        require(land.availableTokens >= _tokenAmount,"Not enough tokens available");

        uint totalCost = land.tokenPrice * _tokenAmount;

        require(msg.value >= totalCost,"Insufficient ETH sent");

        tokenBalances[_landNumber][msg.sender].totalTokens += _tokenAmount;
        tokenBalances[_landNumber][msg.sender].ownershipPercentage = (tokenBalances[_landNumber][msg.sender].totalTokens* 100)/ lands[_landNumber].totalTokens ;
        land.availableTokens -= _tokenAmount;
        payable(land.owner).transfer(totalCost);
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
    }

    function getLandDetails(uint _landNumber)public view returns ( uint,string memory,uint, uint,uint, address)
    {
        Land memory land = lands[_landNumber];
        return (land.landNumber,land.name,land.totalTokens,land.availableTokens,land.tokenPrice,land.owner);
    }

    function getTokenBalance(uint _landNumber,address _user)public view  returns (landOwnership memory)
    {   
        return tokenBalances[_landNumber][_user];
    }
}