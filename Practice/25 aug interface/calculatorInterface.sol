// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ICALCULATOR.sol";

contract calculatorInterface is ICALCULATOR{
    uint temp;
    function add(uint a)external{
        temp += a;
    }
    function sub(uint a)external{
        temp -= a;
    }
    function multi(uint a)external{
        temp *= a;
    }
    function divide(uint a)external{
        temp /= a;
    }
    function result() external view returns(uint){
        return temp;
    }
    function clear() external{
        temp = 0;
    }
}