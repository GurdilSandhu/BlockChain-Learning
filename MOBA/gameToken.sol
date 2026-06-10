// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
 
contract myTokens is ERC20, Ownable{

    constructor(address initialOwner) ERC20("Serial Raw Money", "SRM") Ownable(initialOwner){
        _mint(msg.sender, 1000000 * 10 ** 18);
    }    

    function mintReward(address player, uint256 amount) public onlyOwner {
        _mint(player, amount);
    }
}