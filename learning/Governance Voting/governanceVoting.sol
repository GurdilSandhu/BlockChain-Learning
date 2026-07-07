// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Voting {

    IERC20 public token;
    address public owner;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    modifier onlyOwner{
        require(msg.sender == owner,"Access Denied");
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

    event ProposalExecuted(
        uint256 proposalId,
        bool passed
    );

    function createProposal(
        string memory _description,
        uint256 duration
    ) external {

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
    function vote(
        uint256 proposalId,
        bool support
    ) external {
      
        Proposal storage proposal = proposals[proposalId];

        require(proposal.id != 0, "Proposal doesn't exist");
        require(block.timestamp < proposal.endTime, "Voting ended");
        require(!voted[proposalId][msg.sender], "Already voted");

        uint256 votingPower = token.balanceOf(msg.sender);
        token.transferFrom(msg.sender, address(this), votingPower);

        require(votingPower > 0, "No voting power");

        voted[proposalId][msg.sender] = true;

        if (support) {
            proposal.forVotes += votingPower;
        } else {
            proposal.againstVotes += votingPower;
        }

        emit Voted(
            proposalId,
            msg.sender,
            support,
            votingPower
        );
    }

    function executeProposal(uint256 proposalId) external {

        Proposal storage proposal = proposals[proposalId];

        require(proposal.id != 0, "Proposal doesn't exist");
        require(block.timestamp >= proposal.endTime, "Voting still active");
        require(!proposal.executed, "Already executed");

        proposal.executed = true;

        bool passed = proposal.forVotes > proposal.againstVotes;

        emit ProposalExecuted(
            proposalId,
            passed
        );
    }

    function withdraw() public onlyOwner{
        payable(owner).transfer(address(this).balance);
    }
}