// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract marketSupply{
    address owner;

    constructor(){
        owner = msg.sender;
    }
    
    modifier onlyOwner{
     require(msg.sender == owner,"Access denied");
     _;
    }

    modifier onlyManufacturer{
     require(Detail_Users[msg.sender].role == Role.Manufacturer,"Access denied");
     _;
    }

    modifier onlyDistributer{
     require(Detail_Users[msg.sender].role == Role.Distributer,"Access denied");
     _;
    }

    modifier onlyRetailer{
     require(Detail_Users[msg.sender].role == Role.Retailer,"Access denied");
     _;
    }

    enum Role{Manufacturer, Distributer, Retailer} 

    struct Detail_user{
        uint id;
        address wallet;
        Role role;
    }
    mapping (address => Detail_user) public Detail_Users;
    uint totalUsers;


    struct warehouse{
        uint id;
        string item;
        uint quantity;
        uint price;
    }
    
    mapping(uint => warehouse) public warehouses;
    uint totalItems;

    struct distribution{
        string item;
        uint quantity;
        address retailer;
        uint distribution_price;
    }

    mapping(uint=> distribution)public distributions;
    uint totalDistributions;

    struct selling{
        uint id;
        string item;
        uint quantity;
        uint selling_price;
    }
    uint totalRetails;
    mapping(uint => selling) public retails;
    
    
    function selectRole(uint role) public onlyOwner{
         require(role<=2,"there are only three roles");
         totalUsers++;
         Detail_Users[msg.sender] = Detail_user(totalUsers,msg.sender,Role(role));
    }

    function addItem(string memory item,uint quantity,uint price) public onlyManufacturer{
          require(quantity>0,"quantity will never be zero");
          totalItems++;
          warehouses[totalItems] = warehouse(totalItems,item,quantity,price);
    }

    function addQuantity(uint id,uint quantity) public onlyManufacturer{
        require(id<=totalItems,"item does not exist");
        warehouses[id].quantity+=quantity;
    }

    function distriube(uint _id, uint _quantity, address _retailer, uint price) public onlyDistributer{
        require(_id<=totalItems,"item does not exist");
        warehouses[_id].quantity -= _quantity;
        totalDistributions++;
        distributions[totalDistributions] = distribution(warehouses[_id].item,_quantity,_retailer,price);
    }
    
    function retail(uint _id, uint _quantity, uint price) public onlyRetailer{
        require(_id<=totalItems,"item does not exist");
        require(warehouses[_id].quantity>=_quantity,"not enough quantity");
        warehouses[_id].quantity -= _quantity;
        totalRetails++;
        retails[totalRetails] = selling(totalRetails,warehouses[_id].item,_quantity,price);
    }


}
