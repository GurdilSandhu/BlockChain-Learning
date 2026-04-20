// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// contract Bank{

//     uint Total_balance = 0;

//     //internal check
//     assert(Total_balance>=amount);

//     function deposite(uint amount) public{
        
//         require(amount>0 ,"amount must be greater than 0");
        
//         Total_balance+= amount;
//     }

//     function withdraw(uint amount) public{

//         if(amount>balance){
//             revert()
//         }
//     }

// }


contract BankExample {

    uint public balance = 1000;

    // Add amount
    function deposit(uint amount) public {
        require(amount > 0, "Amount must be greater than 0"); //  input validation

        balance += amount;

        // Internal check (should never fail)
        assert(balance >= amount); //  internal invariant
    }

    // Withdraw amount
    function withdraw(uint amount) public {
        if (amount > balance) {
            revert("Insufficient balance"); //  custom condition
        }

        balance -= amount;

        // Internal safety check
        assert(balance >= 0 && balance>=400);//balance should be greater than 400
    }
}