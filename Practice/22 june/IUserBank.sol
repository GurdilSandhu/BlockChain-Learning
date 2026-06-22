// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


/*
 Interface defines ONLY the functions
 that exist in UserBank and that ATM needs.
*/
interface IUserBank {
     function deposit(address user) external payable;
    function withdraw_cash(address user, uint amount) external;
    function Get_Balance(address user) external view returns (uint);
}

contract SBI_ATM_CASH {

    IUserBank public bank;

    // Pass UserBank contract address while deploying ATM
    constructor(address bank_address) {
        bank = IUserBank(bank_address);
    }

    function Add_Cash() public payable{
        bank.deposit{value: msg.value}(msg.sender);
    }

    function withdraw_Amount(uint amount) public {
        bank.withdraw_cash(msg.sender, amount);
    }

    function Available_Balance(address user) public view returns (uint) {
        return bank.Get_Balance(user);
    }
}