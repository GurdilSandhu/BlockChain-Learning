// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SupplyChain {

    // ===========================
    // ENUMS
    // ===========================

    enum Role {
        None,
        Manufacturer,
        Distributor,
        Retailer,
        Customer
    }

    enum Status {
        Manufactured,
        AtDistributor,
        AtRetailer,
        Delivered
    }

    // ===========================
    // STRUCT
    // ===========================

    struct Product {
        uint256 productId;
        string productName;
        uint256 quantity;
        address currentOwner;
        Status status;
        bool exists;
    }

    // ===========================
    // STATE VARIABLES
    // ===========================

    address public admin;

    mapping(address => Role) public roles;

    mapping(uint256 => Product) public products;

    // ===========================
    // EVENTS
    // ===========================

    event RoleAssigned(
        address indexed user,
        Role role
    );

    event ProductRegistered(
        uint256 indexed productId,
        string productName,
        uint256 quantity
    );

    event OwnershipTransferred(
        uint256 indexed productId,
        address indexed previousOwner,
        address indexed newOwner,
        Status status
    );

    // ===========================
    // CONSTRUCTOR
    // ===========================

    constructor() {
        admin = msg.sender;
    }

    // ===========================
    // MODIFIERS
    // ===========================

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin");
        _;
    }

    modifier onlyManufacturer() {
        require(
            roles[msg.sender] == Role.Manufacturer,
            "Only Manufacturer"
        );
        _;
    }

    modifier onlyDistributor() {
        require(
            roles[msg.sender] == Role.Distributor,
            "Only Distributor"
        );
        _;
    }

    modifier onlyRetailer() {
        require(
            roles[msg.sender] == Role.Retailer,
            "Only Retailer"
        );
        _;
    }

    modifier onlyCustomer() {
        require(
            roles[msg.sender] == Role.Customer,
            "Only Customer"
        );
        _;
    }

    modifier productExists(uint256 _productId) {
        require(
            products[_productId].exists,
            "Product does not exist"
        );
        _;
    }

    // ===========================
    // ROLE MANAGEMENT
    // ===========================

    function assignRole(
        address _user,
        Role _role
    )
        public
        onlyAdmin
    {
        roles[_user] = _role;

        emit RoleAssigned(_user, _role);
    }

    function getRole(address _user)
        public
        view
        returns(Role)
    {
        return roles[_user];
    }

    // ===========================
    // PRODUCT REGISTRATION
    // ===========================

    function registerProduct(
        uint256 _productId,
        string memory _productName,
        uint256 _quantity
    )
        public
        onlyManufacturer
    {
        require(
            !products[_productId].exists,
            "Product already exists"
        );

        require(
            _quantity > 0,
            "Quantity must be greater than zero"
        );

        products[_productId] = Product({
            productId: _productId,
            productName: _productName,
            quantity: _quantity,
            currentOwner: msg.sender,
            status: Status.Manufactured,
            exists: true
        });

        emit ProductRegistered(
            _productId,
            _productName,
            _quantity
        );
    }

    // ===========================
    // TRANSFER TO DISTRIBUTOR
    // ===========================

    function transferToDistributor(
        uint256 _productId,
        address _distributor
    )
        public
        onlyManufacturer
        productExists(_productId)
    {
        Product storage product = products[_productId];

        require(
            product.currentOwner == msg.sender,
            "You are not owner"
        );

        require(
            roles[_distributor] == Role.Distributor,
            "Invalid Distributor"
        );

        address previousOwner = product.currentOwner;

        product.currentOwner = _distributor;
        product.status = Status.AtDistributor;

        emit OwnershipTransferred(
            _productId,
            previousOwner,
            _distributor,
            Status.AtDistributor
        );
    }

    // ===========================
    // TRANSFER TO RETAILER
    // ===========================

    function transferToRetailer(
        uint256 _productId,
        address _retailer
    )
        public
        onlyDistributor
        productExists(_productId)
    {
        Product storage product = products[_productId];

        require(
            product.currentOwner == msg.sender,
            "You are not owner"
        );

        require(
            roles[_retailer] == Role.Retailer,
            "Invalid Retailer"
        );

        address previousOwner = product.currentOwner;

        product.currentOwner = _retailer;
        product.status = Status.AtRetailer;

        emit OwnershipTransferred(
            _productId,
            previousOwner,
            _retailer,
            Status.AtRetailer
        );
    }

    // ===========================
    // DELIVER TO CUSTOMER
    // ===========================

    function deliverToCustomer(
        uint256 _productId,
        address _customer
    )
        public
        onlyRetailer
        productExists(_productId)
    {
        Product storage product = products[_productId];

        require(
            product.currentOwner == msg.sender,
            "You are not owner"
        );

        require(
            roles[_customer] == Role.Customer,
            "Invalid Customer"
        );

        address previousOwner = product.currentOwner;

        product.currentOwner = _customer;
        product.status = Status.Delivered;

        emit OwnershipTransferred(
            _productId,
            previousOwner,
            _customer,
            Status.Delivered
        );
    }

    // ===========================
    // VIEW PRODUCT DETAILS
    // ===========================

    function getProduct(uint256 _productId)
        public
        view
        productExists(_productId)
        returns(
            uint256,
            string memory,
            uint256,
            address,
            Status
        )
    {
        Product memory product = products[_productId];

        return(
            product.productId,
            product.productName,
            product.quantity,
            product.currentOwner,
            product.status
        );
    }
}