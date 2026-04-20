// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Functions{

    string  greetings = "Helloo";
    uint num = 12;

    function sayHello() public pure returns(string memory){
        return "Hello ";
    } 

    function sum(int a, int b) public pure returns(int){
        return a+b;
    }

    // function sayHelloo() public view returns(string memory){
    //     return greetings;
    // }

    function Greet() public view returns(string memory) {
        return greetings;
    }

    function number() public view returns(uint){
        return num;
    }
    
    function sayHelloo() public pure returns(string memory){
        return "Helloo";
    }
}