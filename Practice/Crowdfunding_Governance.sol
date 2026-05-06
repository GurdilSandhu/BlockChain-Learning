// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable{
    address owner;

    constructor(){
         owner = msg.sender;
    }

     modifier onlyOwner(){
        require(msg.sender == owner, "Not owner");
        _;
    }
}



contract crowdGovernance is Ownable{
    
    uint campaignId;
    uint deadline;

    enum CampaignStatus{Active, Paused, Completed, Failed} 
    
    struct Campaign{
       uint id;
       string title;
       address creator;
       uint goal;
       uint timeleft;
       uint fundsRaised;
       CampaignStatus status;
   }   

   uint[] public campaignIds;

   mapping(uint => Campaign) public campaigns;
   mapping(uint => bool) public isCampaignExist;

   function createCampaign(string memory _name,uint _goal, uint _deadline) public{
         campaignId++;
         campaignIds.push(campaignId);
         deadline = block.timestamp + (_deadline * 1 minutes);
         isCampaignExist[campaignId] = true;
         campaigns[campaignId]= Campaign(campaignId,_name,msg.sender,_goal,(block.timestamp + (_deadline * 1 minutes))- block.timestamp,0,CampaignStatus.Active);
   }

   function getCampaign(uint _id) public view onlyOwner returns(uint, string memory, address, uint,uint, uint,CampaignStatus){
    Campaign memory C = campaigns[_id];
    return(C.id,C.title,C.creator,C.goal,C.timeleft,C.fundsRaised,C.status);
   }

   function pauseCampaign(uint _campaignId) public{
         require(msg.sender == campaigns[_campaignId].creator, "Not creator");
         campaigns[_campaignId].status = CampaignStatus.Paused;

   }

   function resumeCampaign(uint _campaignId) public{
        require(msg.sender == campaigns[_campaignId].creator, "Not creator");
         campaigns[_campaignId].status = CampaignStatus.Active;
   }

    struct Contribution{
        address contributor;
        uint amount;
   }

   mapping(uint => Contribution) public contributions;

   modifier notPaused(uint _campaignId){
    require(campaigns[_campaignId].status == CampaignStatus.Active,"Campaign is Paused!!");
    _;
   }

   function addFunds(uint _campaignId) public payable notPaused(_campaignId){
         require(isCampaignExist[_campaignId] == true,"Campaign does not exist");
         require(campaigns[_campaignId].fundsRaised <= campaigns[_campaignId].goal,"Goal Reached");
         require(campaigns[_campaignId].timeleft > 0,"Campaign is over");
         contributions[_campaignId] = Contribution(msg.sender,msg.value);
         campaigns[_campaignId].fundsRaised += msg.value;
         if(campaigns[_campaignId].fundsRaised >= campaigns[_campaignId].goal){
            campaigns[_campaignId].status = CampaignStatus.Completed;
         }
         if(campaigns[_campaignId].timeleft == 0){
            campaigns[_campaignId].status = CampaignStatus.Failed;
         }
   }

    struct Request{
        string description;
        uint amount;
        address payable recipient;
        uint voteCount;
        bool executed;
   }

   mapping(uint => Request) public requests;

   function createRequest(uint _campaignId, string memory desc, uint amount, address recipient) public notPaused(_campaignId){
        require(isCampaignExist[_campaignId] == true,"Campaign does not exist");
        require(msg.sender==campaigns[_campaignId].creator,"Not a Creator");
        require(requests[_campaignId].executed == false,"another request is still in process");
        
        requests[_campaignId] = Request(desc,amount,payable(recipient),0,false);

   }

   mapping(uint => mapping(address => bool)) public voting;

   function addVote(uint _campaignId) public payable notPaused(_campaignId){
    require(isCampaignExist[_campaignId] == true,"Campaign does not exist");
    require(voting[_campaignId][msg.sender]==false && msg.sender == contributions[_campaignId].contributor,"Already Voted or not a contributor!!");
    require(requests[_campaignId].voteCount<3 , "Already executed!!");
    require(requests[_campaignId].amount >= campaigns[_campaignId].fundsRaised,"Not enough funds");

    requests[_campaignId].voteCount++;
    voting[_campaignId][msg.sender] = true;
    if(requests[_campaignId].voteCount == 3){
        payable(requests[_campaignId].recipient).transfer(requests[_campaignId].amount);
        requests[_campaignId].executed = true;
    }
   }
}