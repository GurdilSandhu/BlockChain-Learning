// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./calculatorInterface.sol";

contract calculatorContract is calculatorInterface{

    function Cadd(uint a) public{
        this.add(a);
    }
    function Csub(uint a) public{
        this.sub(a);
    }
    function Cmulti(uint a) public{
        this.multi(a);
    }
    function Cdivide(uint a) public{
        this.divide(a);
    }
    function Cresult() public view returns(uint){
        return this.result();
    }
    function Cclear() public{
        this.clear();
    }
}