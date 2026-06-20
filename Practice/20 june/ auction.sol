// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Auction {
    address public immutable seller;
    uint256 public immutable auctionEndTime;

    address public highestBidder;
    uint256 public highestBid;

    bool public ended;
    bool public itemClaimed;

    mapping(address => uint256) public pendingReturns;

    event BidPlaced(address indexed bidder, uint256 amount);
    event Refunded(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 amount);
    event ItemClaimed(address indexed winner);
    event FundsWithdrawn(address indexed seller, uint256 amount);

    error AuctionAlreadyEnded();
    error AuctionNotYetEnded();
    error BidTooLow();
    error AuctionEndAlreadyCalled();
    error NotWinner();
    error ItemAlreadyClaimed();
    error NoFundsToWithdraw();
    error RefundFailed();
    error NotSeller();
    error NoBids();

    modifier onlySeller() {
        if (msg.sender != seller) revert NotSeller();
        _;
    }

    constructor(uint256 _biddingTimeSeconds) {
        seller = msg.sender;
        auctionEndTime = block.timestamp + _biddingTimeSeconds;
    }

    function bid() external payable {
        if (block.timestamp >= auctionEndTime) revert AuctionAlreadyEnded();
        if (msg.value <= highestBid) revert BidTooLow();

        if (highestBidder != address(0)) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit BidPlaced(msg.sender, msg.value);
    }

    function withdrawRefund() external {
        uint256 amount = pendingReturns[msg.sender];
        if (amount == 0) revert NoFundsToWithdraw();

        pendingReturns[msg.sender] = 0;

        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            pendingReturns[msg.sender] = amount;
            revert RefundFailed();
        }

        emit Refunded(msg.sender, amount);
    }

    function endAuction() external {
        if (block.timestamp < auctionEndTime) revert AuctionNotYetEnded();
        if (ended) revert AuctionEndAlreadyCalled();
        if (highestBidder == address(0)) revert NoBids();

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
    }
    function claimItem() external {
        if (!ended) revert AuctionNotYetEnded();
        if (msg.sender != highestBidder) revert NotWinner();
        if (itemClaimed) revert ItemAlreadyClaimed();

        itemClaimed = true;
        emit ItemClaimed(msg.sender);

    }

    function withdrawFunds() external onlySeller {
        if (!ended) revert AuctionNotYetEnded();
        uint256 amount = highestBid;
        if (amount == 0) revert NoFundsToWithdraw();

        highestBid = 0; 

        (bool success, ) = seller.call{value: amount}("");
        if (!success) revert RefundFailed();

        emit FundsWithdrawn(seller, amount);
    }

    function timeRemaining() external view returns (uint256) {
        if (block.timestamp >= auctionEndTime) return 0;
        return auctionEndTime - block.timestamp;
    }
}