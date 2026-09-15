// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// using github path
import "https://github.com/sachinsharma0007/tp_contracts/blob/main/TP_1.sol";

//using interface

// interface ITP1{
//     function add_money(uint amount) external;
//     function get_balance() external view returns(uint);
// }

contract TP2 {
    //using github path
    TP Contract2;

    constructor (address TP_address){

     Contract2 = TP(TP_address); 
    }

    function addcash(uint _amount) public {
        Contract2.add_money(_amount);
    }

    //using interface
    // ITP1 Contract2;

    // constructor (address TP_address){

    //  Contract2 = ITP1(TP_address); 
    // }

    // function addcash(uint _amount) public {
    //     Contract2.add_money(_amount);
    // }

    // function getBalance() public view returns(uint){
    //    return Contract2.get_balance();
    // }

}