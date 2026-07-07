// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auction {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    event AuctionCreated(uint auctionId, address seller, string item, string IPFS_CID, uint startingBid, uint endTime);
    event Bid(uint auctionId, address bidder, uint amount);
    event AuctionCompleted(uint auctionId, address winner, uint winningBid);
    event Withdrawal(address user, uint amount);

    struct Auct {
        uint auctionId;
        address seller;
        string item;
        string IPFS_CID;
        uint startingBid;
        uint highestBid;
        address highestBidder;
        uint time; 
        bool isActive;
        bool isSettled;
    }

    struct Bidder {
        address bidder;
        uint bidAmount;
    }

    mapping(uint => Auct) public auctions;

    mapping(uint => mapping(uint => Bidder)) public bidders;         
    mapping(uint => uint) public totalBiddersOf;                     
    mapping(uint => mapping(address => bool)) public bidderExists;   
    mapping(uint => mapping(address => uint)) public bidderIndexOf;   

    mapping(address => uint) public pendingBalance;

    uint public totalAuctions;

    function createAuction(string memory item, string memory IPFS_CID, uint startingBid, uint duration) public {
        require(startingBid >= 1 ether, "Starting bid must be at least 1 ether");
        require(bytes(item).length > 0, "Item name must not be empty");
        require(bytes(IPFS_CID).length > 0, "IPFS CID must not be empty");
        require(duration > 0, "Duration must be greater than 0");

        totalAuctions += 1;
        uint endTime = block.timestamp + duration;

        auctions[totalAuctions] = Auct({
            auctionId: totalAuctions,
            seller: msg.sender,
            item: item,
            IPFS_CID: IPFS_CID,
            startingBid: startingBid,
            highestBid: 0,
            highestBidder: address(0),
            time: endTime,
            isActive: true,
            isSettled: false
        });

        emit AuctionCreated(totalAuctions, msg.sender, item, IPFS_CID, startingBid, endTime);
    }

    function placeBid(uint auctionId) public payable {
        Auct storage a = auctions[auctionId];

        require(a.isActive, "Auction is not active");
        require(block.timestamp < a.time, "Auction has ended");
        require(msg.sender != a.seller, "Seller cannot bid");
        require(msg.value > 0, "Bid amount must be greater than 0");

        uint newTotal;

        if (!bidderExists[auctionId][msg.sender]) {
            newTotal = msg.value;
            require(newTotal >= a.startingBid, "Bid below starting bid");

            totalBiddersOf[auctionId] += 1;
            uint idx = totalBiddersOf[auctionId];

            bidders[auctionId][idx] = Bidder({bidder: msg.sender, bidAmount: msg.value});
            bidderExists[auctionId][msg.sender] = true;
            bidderIndexOf[auctionId][msg.sender] = idx;
        } else {
            uint idx = bidderIndexOf[auctionId][msg.sender];
            newTotal = bidders[auctionId][idx].bidAmount + msg.value;
            bidders[auctionId][idx].bidAmount = newTotal;
        }

        require(newTotal > a.highestBid, "Bid must exceed current highest bid");

        a.highestBid = newTotal;
        a.highestBidder = msg.sender;

        emit Bid(auctionId, msg.sender, msg.value);
    }

    function hasTimeExpired(uint auctionId) public view returns (bool) {
        return block.timestamp >= auctions[auctionId].time;
    }

    function endAuction(uint auctionId) public {
        Auct storage a = auctions[auctionId];
        require(a.isActive, "Auction is not active");
        require(block.timestamp >= a.time, "Auction has not ended yet");

        _settleAuction(auctionId);
    }

    function _settleAuction(uint auctionId) internal {
        Auct storage a = auctions[auctionId];
        require(a.isActive, "Auction is not active");
        require(!a.isSettled, "Auction already settled");

        uint count = totalBiddersOf[auctionId];

        if (count == 0) {
            a.isActive = false;
            a.isSettled = true;
            emit AuctionCompleted(auctionId, address(0), 0);
            return;
        }

        address winner = a.highestBidder;
        uint winningBid = a.highestBid;

        a.isActive = false;
        a.isSettled = true;

        pendingBalance[a.seller] += winningBid;

        for (uint i = 1; i <= count; i++) {
            Bidder storage b = bidders[auctionId][i];
            if (b.bidder != winner && b.bidAmount > 0) {
                pendingBalance[b.bidder] += b.bidAmount;
                b.bidAmount = 0;
            }
        }

        emit AuctionCompleted(auctionId, winner, winningBid);
    }

    function withdraw() public {
        uint amount = pendingBalance[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        pendingBalance[msg.sender] = 0; 

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Withdrawal failed");

        emit Withdrawal(msg.sender, amount);
    }
}
