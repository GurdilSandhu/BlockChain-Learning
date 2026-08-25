// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICALCULATOR {
    function add(uint a)external;
    function sub(uint a)external;
    function multi(uint a)external;
    function divide(uint a)external;
    function result()external view returns(uint);
    function clear()external;
}