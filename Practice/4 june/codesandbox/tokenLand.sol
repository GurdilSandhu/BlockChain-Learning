// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenLand {
    event LandTokenized(
        uint indexed landNumber,
        address indexed owner,
        uint totalTokens
    );

    event TokensPurchased(
        uint indexed landNumber,
        address indexed buyer,
        uint tokenAmount
    );

    event OwnershipTransferred(
        uint indexed landNumber,
        address indexed from,
        address indexed to,
        uint tokenAmount
    );

    struct Land {
        uint landNumber;
        string name;
        string location;
        uint area;
        string documentCID;
        uint totalTokens;
        uint availableTokens;
        uint tokenPrice;
        address issuer;
        uint timestamp;
    }

    struct landOwnership {
        uint totalTokens;
        uint ownershipPercentage;
    }

    struct Listing {
        uint landNumber;
        address seller;
        uint tokenAmount;
        uint pricePerToken;
        bool active;
    }

    uint public nextListingId;

    mapping(uint => Listing) public listings;

    uint[] public landIds;
    mapping(uint => Land) public lands;
    mapping(uint => bool) public isExist;
    mapping(uint => address[]) public shareholders;
    mapping(uint => mapping(address => bool)) public isShareholder;
    mapping(uint => mapping(address => landOwnership)) public tokenBalances;

    function tokenizeLand(
        uint _landNumber,
        string memory _name,
        string memory _location,
        uint _area,
        string memory _documentCID,
        uint _totalTokens,
        uint _landPrice,
        uint _reservedTokens
    ) public {
        require(!isExist[_landNumber], "Land already tokenized");
        require(_totalTokens > 0, "Invalid token amount");
        require(_landPrice > 0, "Invalid land price");
        require(_reservedTokens <= _totalTokens, "Invalid reserve");

        uint tokenPrice = (_landPrice * 1 ether) / _totalTokens;

        lands[_landNumber] = Land({
            landNumber: _landNumber,
            name: _name,
            location: _location,
            area: _area,
            documentCID: _documentCID,
            totalTokens: _totalTokens,
            availableTokens: _totalTokens - _reservedTokens,
            tokenPrice: tokenPrice,
            issuer: msg.sender,
            timestamp: block.timestamp
        });
        tokenBalances[_landNumber][msg.sender] = landOwnership({
            totalTokens: _reservedTokens,
            ownershipPercentage: (_reservedTokens * 100) / _totalTokens
        });
        landIds.push(_landNumber);
        isExist[_landNumber] = true;
        if (_reservedTokens != 0) {
            isShareholder[_landNumber][msg.sender] = true;
            shareholders[_landNumber].push(msg.sender);
        }
        emit LandTokenized(_landNumber, msg.sender, _totalTokens);
    }

    function buyToken(uint _landNumber, uint _tokenAmount) public payable {
        require(isExist[_landNumber], "Land not tokenized");
        require(_tokenAmount > 0, "Invalid token amount");

        Land storage land = lands[_landNumber];

        require(
            land.availableTokens >= _tokenAmount,
            "Not enough tokens available"
        );

        uint totalCost = land.tokenPrice * _tokenAmount;

        require(msg.value >= totalCost, "Insufficient ETH sent");
        tokenBalances[_landNumber][msg.sender].totalTokens += _tokenAmount;
        tokenBalances[_landNumber][msg.sender].ownershipPercentage =
            (tokenBalances[_landNumber][msg.sender].totalTokens * 100) /
            lands[_landNumber].totalTokens;
        land.availableTokens -= _tokenAmount;
        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }
        payable(land.issuer).transfer(totalCost);
        if (!isShareholder[_landNumber][msg.sender]) {
            isShareholder[_landNumber][msg.sender] = true;
            shareholders[_landNumber].push(msg.sender);
        }

        emit TokensPurchased(_landNumber, msg.sender, _tokenAmount);
    }

    function sell_tokens_shareHolder(
        uint _landNumber,
        uint _tokenAmount,
        uint _pricePerToken
    ) public {
        require(
            isShareholder[_landNumber][msg.sender] == true,
            "Not share Holder"
        );
        require(
            tokenBalances[_landNumber][msg.sender].totalTokens >= _tokenAmount,
            "Not enough tokens"
        );
        createListing(_landNumber, _tokenAmount, _pricePerToken);

        if (tokenBalances[_landNumber][msg.sender].totalTokens == 0) {
            removeShareholder(_landNumber, msg.sender);
        }
    }

    function removeShareholder(uint _landNumber, address _holder) internal {
        isShareholder[_landNumber][_holder] = false;

        address[] storage holders = shareholders[_landNumber];

        for (uint i = 0; i < holders.length; i++) {
            if (holders[i] == _holder) {
                holders[i] = holders[holders.length - 1];

                holders.pop();

                break;
            }
        }
    }

    function createListing(
        uint _landNumber,
        uint _tokenAmount,
        uint _pricePerToken
    ) internal {
        require(
            tokenBalances[_landNumber][msg.sender].totalTokens >= _tokenAmount,
            "Insufficient balance"
        );

        listings[nextListingId] = Listing({
            landNumber: _landNumber,
            seller: msg.sender,
            tokenAmount: _tokenAmount,
            pricePerToken: _pricePerToken,
            active: true
        });

        nextListingId++;
    }

    function buyListedTokens(uint listingId, uint _tokenAmount) public payable {
        Listing storage listing = listings[listingId];

        require(listing.active, "Listing inactive");
        require(
            tokenBalances[listing.landNumber][listing.seller].totalTokens >=
                _tokenAmount,
            "Not valid amount"
        );

        uint cost = _tokenAmount * listing.pricePerToken;

        require(msg.value >= cost, "Insufficient ETH");

        tokenBalances[listing.landNumber][listing.seller]
            .totalTokens -= _tokenAmount;
             tokenBalances[listing.landNumber][listing.seller].ownershipPercentage =
            (tokenBalances[listing.landNumber][listing.seller].totalTokens * 100) /
            lands[listing.landNumber].totalTokens;

        tokenBalances[listing.landNumber][msg.sender].totalTokens += listing
            .tokenAmount;

        tokenBalances[listing.landNumber][msg.sender].ownershipPercentage =
            (tokenBalances[listing.landNumber][msg.sender].totalTokens * 100) /
            lands[listing.landNumber].totalTokens;

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        payable(listing.seller).transfer(cost);

        if (listing.tokenAmount == 0) {
            listing.active = false;
        }

        if (!isShareholder[listing.landNumber][msg.sender]) {
            shareholders[listing.landNumber].push(msg.sender);
            isShareholder[listing.landNumber][msg.sender] = true;
        }
    }

    function getLandDetails(
        uint _landNumber
    )
        public
        view
        returns (
            uint,
            string memory,
            string memory,
            uint,
            string memory,
            uint,
            uint,
            uint,
            address,
            uint
        )
    {
        Land memory land = lands[_landNumber];

        return (
            land.landNumber,
            land.name,
            land.location,
            land.area,
            land.documentCID,
            land.totalTokens,
            land.availableTokens,
            land.tokenPrice,
            land.issuer,
            land.timestamp
        );
    }

    function getOwnershipPercentage(
        uint _landNumber,
        address _user
    ) public view returns (uint) {
        return
            (tokenBalances[_landNumber][_user].totalTokens * 100) /
            lands[_landNumber].totalTokens;
    }

    function updateDocumentCID(uint _landNumber, string memory _newCID) public {
        require(msg.sender == lands[_landNumber].issuer, "Only owner");

        lands[_landNumber].documentCID = _newCID;
    }

    function getAllLandIds() public view returns (uint[] memory) {
        return landIds;
    }

    function getAllLands() public view returns (Land[] memory) {
        Land[] memory allLands = new Land[](landIds.length);

        for (uint i = 0; i < landIds.length; i++) {
            allLands[i] = lands[landIds[i]];
        }

        return allLands;
    }
}
