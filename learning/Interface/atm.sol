// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./bank.sol";


contract atm{
    UserBank public bank1;
    
    constructor(address bank_address){
        bank1 = UserBank(bank_address);
    }

    function deposit() external payable {
         require(msg.value > 0,"add some funds");
         bank1.deposit();
    }

    function getMyBalance() external view returns(uint){
        return bank1.getMyBalance();
    }

    function withdraw(uint amount) external payable{
        // require(bank.[msg.sender] >= amount ,"No Funds");
        bank1.withdraw(amount);
    }

}


interface UserBank {

     function deposit() external payable;
     function withdraw(uint amount) external payable;
     function getMyBalance() external view returns(uint);
    
}