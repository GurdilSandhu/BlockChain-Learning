// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TeacherCourse.sol";

contract StudentOffer {

    TeacherCourse courseContract;

    constructor(address _courseAddress) {
        courseContract = TeacherCourse(_courseAddress);
    }

    struct Offer {
        uint offeredPrice;
        bool exists;
    }

    mapping(address => Offer) public offers;

    function submitOffer(uint _price) public {

        (, , uint actualFee) = courseContract.getCourse();

        require(_price > 0, "Invalid price");
        require(_price < actualFee, "Offer must be less than actual fee");

        offers[msg.sender] = Offer(_price, true);
    }

    function getMyOffer() public view returns (uint) {
        require(offers[msg.sender].exists, "No offer found");
        return offers[msg.sender].offeredPrice;
    }
}