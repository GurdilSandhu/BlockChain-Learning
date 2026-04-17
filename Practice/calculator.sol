// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Calculator{

    uint public result;

    event Calculation(string operation, uint value, uint result);

    function Addvalue(uint _value) public{
        result += _value;
        emit Calculation("ADD", _value, result);
    }

    function Multiplyvalue(uint _value) public{
        result *= _value;
        emit Calculation("MULTI", _value, result);
    }

    function Dividevalue(uint _value) public{
        result/= _value;
        emit Calculation("DIV", _value, result);
    }

    function Subvalue(uint _value) public{
        result-= _value;
        emit Calculation("SUB", _value, result);
    }
} 