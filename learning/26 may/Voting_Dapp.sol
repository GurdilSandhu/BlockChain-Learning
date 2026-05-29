// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {

    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    address public owner;

    mapping(uint => Candidate) private candidates;   // CHANGED
    mapping(address => bool) private hasVoted;

    uint public candidatesCount;
    uint private totalVoters;

    event Voted(uint indexed candidateId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
        addCandidate("Guddu Pandit");
        addCandidate("Munna Bhaiya");
        addCandidate("Golu Gupta");
    }

    function addCandidate(string memory _name) private {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, _name, 0);
    }

    function vote(uint _candidateId) public {
        require(!hasVoted[msg.sender], "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid candidate ID");

        hasVoted[msg.sender] = true;
        candidates[_candidateId].voteCount++;
        totalVoters++;

        emit Voted(_candidateId);
    }

    //  Only owner can see total voters
    function getTotalVoters() public view onlyOwner returns (uint) {
        return totalVoters;
    }

    //  Only owner can see vote count
    function getCandidate(uint _candidateId)
        public
        view
        onlyOwner
        returns (uint, string memory, uint)
    {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid ID");

        Candidate memory c = candidates[_candidateId];
        return (c.id, c.name, c.voteCount);
    }

    //  Public function for normal users (NO vote count)
    function getCandidateBasic(uint _candidateId)
        public
        view
        returns (uint, string memory)
    {
        require(_candidateId > 0 && _candidateId <= candidatesCount, "Invalid ID");

        Candidate memory c = candidates[_candidateId];
        return (c.id, c.name);
    }
}