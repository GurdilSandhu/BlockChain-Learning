// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


interface IExchange {
    function getPrice(uint token) external view returns (uint256);
    function swap(uint tokenIn,uint tokenOut,uint256 amount) external view returns (uint256); 
}

contract trader{
    IExchange public exchange;

    constructor(address exchangeAddress){
        exchange = IExchange(exchangeAddress);
    }

    function getPrice(uint token)public view returns(uint price){
        return exchange.getPrice(token);
    }

    function swap(uint tokenIn, uint tokenOut,uint amount) public view returns(uint amountOut){
        return exchange.swap(tokenIn, tokenOut, amount);
    }
}