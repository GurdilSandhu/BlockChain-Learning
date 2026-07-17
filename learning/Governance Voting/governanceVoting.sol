// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Voting {
    using SafeERC20 for IERC20;

    IERC20 public token;
    address public owner;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access Denied");
        _;
    }

    struct Proposal {
        uint256 id;
        string description;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    uint256 public proposalCount;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public voted;

    event ProposalCreated(
        uint256 proposalId,
        string description,
        uint256 endTime
    );

    event Voted(
        uint256 proposalId,
        address voter,
        bool support,
        uint256 votingPower
    );

    event ProposalExecuted(uint256 proposalId, bool passed);

    function createProposal(
        string memory _description,
        uint256 duration
    ) external onlyOwner {
        require(duration > 0, "Duration must be > 0");

        proposalCount++;

        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            endTime: block.timestamp + duration,
            forVotes: 0,
            againstVotes: 0,
            executed: false
        });

        emit ProposalCreated(
            proposalCount,
            _description,
            block.timestamp + duration
        );
    }

    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = proposals[proposalId];

        require(proposal.id != 0, "Proposal doesn't exist");
        require(block.timestamp < proposal.endTime, "Voting ended");
        require(!voted[proposalId][msg.sender], "Already voted");

        uint256 votingPower;
        if(token.balanceOf(msg.sender) >= 1){
            votingPower = 1;
        }else{
            votingPower = 0;
        }
        require(votingPower > 0, "No voting power");

        voted[proposalId][msg.sender] = true;

        if (support) {
            proposal.forVotes += votingPower;
        } else {
            proposal.againstVotes += votingPower;
        }

        emit Voted(proposalId, msg.sender, support, votingPower);

        token.safeTransferFrom(msg.sender, address(this), votingPower);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];

        require(proposal.id != 0, "Proposal doesn't exist");
        require(block.timestamp >= proposal.endTime, "Voting still active");
        require(!proposal.executed, "Already executed");

        proposal.executed = true;

        bool passed = proposal.forVotes > proposal.againstVotes;

        emit ProposalExecuted(proposalId, passed);
    }

    function withdrawTokens(uint proposalId) external onlyOwner {
        require(proposals[proposalId].executed,"Still not executed!");
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens");

        token.safeTransfer(owner, balance);
    }

    function getAllProposals() external view returns (Proposal[] memory) {
        Proposal[] memory list = new Proposal[](proposalCount);

        for (uint256 i = 0; i < proposalCount; i++) {
            list[i] = proposals[i + 1];
        }

        return list;
    }

    function getProposalCount() external view returns (uint256) {
          return proposalCount;
    }

    function hasVoted(
        uint256 proposalId,
        address user
    ) external view returns (bool) {
        return voted[proposalId][user];
    }

    function getVotingPower(address user) external view returns (uint256) {
        return token.balanceOf(user);
    }

    function getProposalStatus(
        uint256 proposalId
    ) external view returns (string memory) {
        Proposal memory p = proposals[proposalId];

        if (p.executed) {
            return "Executed";
        }

        if (block.timestamp < p.endTime) {
            return "Voting";
        }

        return "Ended";
    }

    function proposalPassed(uint256 proposalId) external view returns (bool) {
        Proposal memory p = proposals[proposalId];
        return p.forVotes > p.againstVotes;
    }

    function getRemainingTime(
        uint256 proposalId
    ) external view returns (uint256) {
        Proposal memory p = proposals[proposalId];

        if (block.timestamp >= p.endTime) {
            return 0;
        }

        return p.endTime - block.timestamp;
    }

    function getAllProposalIds() external view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](proposalCount);

        for (uint256 i = 0; i < proposalCount; i++) {
            ids[i] = i + 1;
        }

        return ids;
    }
}