// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ICALCULATOR.sol";

contract newCalculator{
    ICALCULATOR public calc;

    constructor(address calculatorAddress) {
        calc = ICALCULATOR(calculatorAddress);
    }

   function add(uint a)public {
        calc.add(a);
    }

    function result() public view returns(uint){
        return calc.result();
    }
    function add1(uint a) public pure returns(uint ){
       return a+a;
    }

}