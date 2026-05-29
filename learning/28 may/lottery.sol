// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract lottery{
    address manager;

    constructor(){
        manager = msg.sender;
    }

    address[] players;
    mapping (address => bool) isEntered;
    address winner;

    function addLottery()public payable {
        require(!isEntered[msg.sender],"Already Entered");
        require(msg.value >= 1 ether,"atleast 1 ether required");
       players.push(msg.sender);
       isEntered[msg.sender] = true;
    }

    function random()private view returns(uint){
        require(players.length>0,"No entry yet!!");
        return  block.timestamp % players.length;
    }

    function pickWinner()public returns(address){
        require(msg.sender == manager,"Access only to manager");
        require(players.length>0,"Not enough enteries");
        winner = players[random()];
        for(uint i = 0; i < players.length; i++) {
            isEntered[players[i]] = false;
        }
        players = new address[](0);
        (bool success, ) = payable(winner).call{value: address(this).balance}("");
        require(success, "Transfer failed");
        return winner;
    }

    function showPlayers() public view returns(address[] memory){
        // require(players.length > 0,"No Entry yet");
        return players;
    }

    function showWinner() public view returns(address){
        return winner;
    }

}