// Design a contract for booking event tickets with limited availability.

// Requirements:
// Total tickets are fixed
// Users can book tickets
// Track total tickets sold

// Conditions:
// Cannot book zero tickets
// Cannot book more tickets than available
// Total sold tickets should never exceed the maximum limit

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TicketBooking{
    uint Total_tickets = 100;
    uint Tickets_sold;

    function book(uint tickets) public{
        require(tickets>0,"Insufficient Tickets");
        require(tickets<=100,"Limited Tickets only 100");

        Total_tickets-=tickets;
        Tickets_sold += tickets;

        assert(Total_tickets>=0);
    }

    function Total_tickets_sold() view public returns(uint){
        return Tickets_sold;
    }
}