//  Inventory Management with Access Restrictions

// Created a contract to manage product stock. The contract owner is able to add 
// and update product quantities. Each product have a valid stock value. 
// Maintained list of all product identifiers and prevent duplicate entries. 
// Users are able to reduce stock when purchasing, ensuring stock never goes negative.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Inventory_Management{
    address owner;
    uint[] productID;
    mapping (uint => uint) product_stock;
    mapping (uint => bool) isExisted;

    constructor(){
        owner=msg.sender;
    }

    modifier checkOwner{
        require(owner==msg.sender,"Access Denied");
        _;
    }

    function addProduct(uint id,uint quantity) public checkOwner{
        require(!isExisted[id],"Id already exist");
       
        productID.push(id);
        product_stock[id]=quantity;
        isExisted[id]=true;
    }

    function updateProduct(uint id,uint quantity) public checkOwner{
        require(!isExisted[id],"Id does not exist");
       
        productID.push(id);
        product_stock[id]=quantity;
        isExisted[id]=true;
    }

    function buyProduct(uint id, uint quantity) public {
        require(isExisted[id],"Invalid Id");
        require(product_stock[id]>=quantity,"Invalid quantity");
     
        product_stock[id]-=quantity;

        assert(product_stock[id]>=0);
    }

     function getFullDetails() public view returns (uint[] memory, uint[] memory) {
        uint[] memory all_products=new uint[](productID.length);
        for (uint i = 0; i < productID.length; i++) {
            all_products[i]= product_stock[productID[i]];
        }

        return (productID, all_products);
    }
}