// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract mockExchange{
    mapping(uint => uint) prices;

    constructor(uint A_price, uint B_price){
         prices[0] = A_price;
         prices[1] = B_price;
    }

    function getPrice(uint token) external view returns(uint256 price){
        price = prices[token];
        return price;
     }

    function swap(uint tokenIn,uint tokenOut,uint256 amount) external view returns (uint256 amountOut){
          require(tokenIn<2 && tokenOut<2,"Invalid tokens");
          require(amount>0,"Amount should be greater than zero");

          amountOut = (amount * prices[tokenIn]) / prices[tokenOut];
          return amountOut;
     }
    
}