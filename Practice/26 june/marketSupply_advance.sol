// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MarketSupply {
    enum Role { None, Manufacturer, Distributor, Retailer }

    struct User {
        uint256 id;
        address wallet;
        Role role;
        bool active;
    }

    struct Item {
        uint256 id;
        string name;
        uint256 quantity;
        uint256 price;
        address manufacturer;
        bool exists;
    }

    struct Distribution {
        uint256 id;
        uint256 itemId;
        string item;
        uint256 quantity;
        address distributor;
        address retailer;
        uint256 unitPrice;
        uint256 totalPaid;
        uint256 timestamp;
    }

    struct Listing {
        uint256 id;
        uint256 itemId;
        string item;
        uint256 quantity;
        uint256 unitPrice;
        address retailer;
        bool active;
    }

    address public owner;
    bool public paused;

    mapping(address => User) public users;
    uint256 public totalUsers;

    mapping(uint256 => Item) public inventory;
    uint256 public totalItems;

    mapping(uint256 => Distribution) public distributions;
    uint256 public totalDistributions;

    mapping(uint256 => Listing) public listings;
    uint256 public totalListings;

    mapping(address => mapping(uint256 => uint256)) public retailerStock;
    mapping(address => uint256) public pendingWithdrawals;
    uint256 private locked;

    event UserRegistered(address indexed user, Role role, uint256 id);
    event UserRevoked(address indexed user);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address indexed by);
    event Unpaused(address indexed by);
    event ItemAdded(uint256 indexed itemId, string name, uint256 quantity, uint256 price, address indexed manufacturer);
    event QuantityAdded(uint256 indexed itemId, uint256 addedQuantity, uint256 newQuantity);
    event PriceUpdated(uint256 indexed itemId, uint256 oldPrice, uint256 newPrice);
    event ItemDistributed(uint256 indexed distributionId, uint256 indexed itemId, address indexed distributor, address retailer, uint256 quantity, uint256 totalPaid);
    event ItemListed(uint256 indexed listingId, uint256 indexed itemId, address indexed retailer, uint256 quantity, uint256 unitPrice);
    event ListingClosed(uint256 indexed listingId);
    event ItemPurchased(uint256 indexed listingId, address indexed buyer, uint256 quantity, uint256 totalPaid);
    event Withdrawn(address indexed account, uint256 amount);

    error NotOwner();
    error NotManufacturer();
    error NotDistributor();
    error NotRetailer();
    error ContractPaused();
    error ReentrantCall();
    error ZeroAddress();
    error InvalidRole();
    error AlreadyRegistered();
    error NotRegistered();
    error EmptyName();
    error ItemNotFound();
    error ListingNotFound();
    error InsufficientQuantity();
    error InsufficientPayment();
    error ZeroAmount();
    error TransferFailed();

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyManufacturer() {
        if (!users[msg.sender].active || users[msg.sender].role != Role.Manufacturer) revert NotManufacturer();
        _;
    }

    modifier onlyDistributor() {
        if (!users[msg.sender].active || users[msg.sender].role != Role.Distributor) revert NotDistributor();
        _;
    }

    modifier onlyRetailer() {
        if (!users[msg.sender].active || users[msg.sender].role != Role.Retailer) revert NotRetailer();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    modifier nonReentrant() {
        if (locked == 1) revert ReentrantCall();
        locked = 1;
        _;
        locked = 0;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerUser(address account, uint8 role) external onlyOwner {
        if (account == address(0)) revert ZeroAddress();
        if (role == 0 || role > uint8(Role.Retailer)) revert InvalidRole();
        if (users[account].active) revert AlreadyRegistered();

        totalUsers++;
        users[account] = User(totalUsers, account, Role(role), true);
        emit UserRegistered(account, Role(role), totalUsers);
    }

    function revokeUser(address account) external onlyOwner {
        if (!users[account].active) revert NotRegistered();
        users[account].active = false;
        emit UserRevoked(account);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function pause() external onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyOwner {
        paused = false;
        emit Unpaused(msg.sender);
    }

    function addItem(string calldata name, uint256 quantity, uint256 price) external onlyManufacturer whenNotPaused returns (uint256 itemId) {
        if (bytes(name).length == 0) revert EmptyName();
        if (quantity == 0 || price == 0) revert ZeroAmount();

        totalItems++;
        inventory[totalItems] = Item(totalItems, name, quantity, price, msg.sender, true);
        emit ItemAdded(totalItems, name, quantity, price, msg.sender);
        return totalItems;
    }

    function addQuantity(uint256 itemId, uint256 quantity) external onlyManufacturer whenNotPaused {
        Item storage it = inventory[itemId];
        if (!it.exists) revert ItemNotFound();
        if (it.manufacturer != msg.sender) revert NotManufacturer();
        if (quantity == 0) revert ZeroAmount();

        it.quantity += quantity;
        emit QuantityAdded(itemId, quantity, it.quantity);
    }

    function updatePrice(uint256 itemId, uint256 newPrice) external onlyManufacturer whenNotPaused {
        Item storage it = inventory[itemId];
        if (!it.exists) revert ItemNotFound();
        if (it.manufacturer != msg.sender) revert NotManufacturer();
        if (newPrice == 0) revert ZeroAmount();

        uint256 old = it.price;
        it.price = newPrice;
        emit PriceUpdated(itemId, old, newPrice);
    }

    function distributeItem(uint256 itemId, uint256 quantity, address retailer) external payable onlyDistributor whenNotPaused nonReentrant returns (uint256 distributionId) {
        if (retailer == address(0)) revert ZeroAddress();
        if (!users[retailer].active || users[retailer].role != Role.Retailer) revert NotRetailer();

        Item storage it = inventory[itemId];
        if (!it.exists) revert ItemNotFound();
        if (quantity == 0) revert ZeroAmount();
        if (it.quantity < quantity) revert InsufficientQuantity();

        uint256 totalCost = it.price * quantity;
        if (msg.value < totalCost) revert InsufficientPayment();

        it.quantity -= quantity;
        retailerStock[retailer][itemId] += quantity;

        totalDistributions++;
        distributions[totalDistributions] = Distribution(totalDistributions, itemId, it.name, quantity, msg.sender, retailer, it.price, totalCost, block.timestamp);

        pendingWithdrawals[it.manufacturer] += totalCost;
        uint256 refund = msg.value - totalCost;
        if (refund > 0) {
            pendingWithdrawals[msg.sender] += refund;
        }

        emit ItemDistributed(totalDistributions, itemId, msg.sender, retailer, quantity, totalCost);
        return totalDistributions;
    }

    function listForSale(uint256 itemId, uint256 quantity, uint256 unitPrice) external onlyRetailer whenNotPaused returns (uint256 listingId) {
        if (quantity == 0 || unitPrice == 0) revert ZeroAmount();
        if (retailerStock[msg.sender][itemId] < quantity) revert InsufficientQuantity();

        Item storage it = inventory[itemId];
        if (!it.exists) revert ItemNotFound();

        retailerStock[msg.sender][itemId] -= quantity;
        totalListings++;
        listings[totalListings] = Listing(totalListings, itemId, it.name, quantity, unitPrice, msg.sender, true);
        emit ItemListed(totalListings, itemId, msg.sender, quantity, unitPrice);
        return totalListings;
    }

    function closeListing(uint256 listingId) external onlyRetailer {
        Listing storage l = listings[listingId];
        if (!l.active) revert ListingNotFound();
        if (l.retailer != msg.sender) revert NotRetailer();

        l.active = false;
        if (l.quantity > 0) {
            retailerStock[msg.sender][l.itemId] += l.quantity;
            l.quantity = 0;
        }
        emit ListingClosed(listingId);
    }

    function buy(uint256 listingId, uint256 quantity) external payable whenNotPaused nonReentrant {
        Listing storage l = listings[listingId];
        if (!l.active) revert ListingNotFound();
        if (quantity == 0) revert ZeroAmount();
        if (l.quantity < quantity) revert InsufficientQuantity();

        uint256 totalCost = l.unitPrice * quantity;
        if (msg.value < totalCost) revert InsufficientPayment();

        l.quantity -= quantity;
        if (l.quantity == 0) {
            l.active = false;
        }

        pendingWithdrawals[l.retailer] += totalCost;
        uint256 refund = msg.value - totalCost;
        if (refund > 0) {
            pendingWithdrawals[msg.sender] += refund;
        }

        emit ItemPurchased(listingId, msg.sender, quantity, totalCost);
    }

    function withdraw() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        if (amount == 0) revert ZeroAmount();

        pendingWithdrawals[msg.sender] = 0;
        (bool ok, ) = payable(msg.sender).call{value: amount}("");
        if (!ok) revert TransferFailed();

        emit Withdrawn(msg.sender, amount);
    }

    function getUser(address account) external view returns (User memory) {
        return users[account];
    }

    function getUserRole(address account) external view returns (Role) {
        return users[account].role;
    }

    function isManufacturer(address account) external view returns (bool) {
        return users[account].active && users[account].role == Role.Manufacturer;
    }

    function isDistributor(address account) external view returns (bool) {
        return users[account].active && users[account].role == Role.Distributor;
    }

    function isRetailer(address account) external view returns (bool) {
        return users[account].active && users[account].role == Role.Retailer;
    }

    function myBalance() external view returns (uint256) {
        return pendingWithdrawals[msg.sender];
    }

    function getItem(uint256 itemId) external view returns (Item memory) {
        return inventory[itemId];
    }

    function getDistribution(uint256 id) external view returns (Distribution memory) {
        return distributions[id];
    }

    function getListing(uint256 id) external view returns (Listing memory) {
        return listings[id];
    }

    function quoteDistributionCost(uint256 itemId, uint256 quantity) external view returns (uint256) {
        Item storage it = inventory[itemId];
        if (!it.exists) revert ItemNotFound();
        if (it.quantity < quantity) revert InsufficientQuantity();
        return it.price * quantity;
    }

    function quoteListingCost(uint256 listingId, uint256 quantity) external view returns (uint256) {
        Listing storage l = listings[listingId];
        if (!l.active) revert ListingNotFound();
        if (l.quantity < quantity) revert InsufficientQuantity();
        return l.unitPrice * quantity;
    }

    function getAllItems() external view returns (Item[] memory) {
        Item[] memory result = new Item[](totalItems);
        for (uint256 i = 1; i <= totalItems; i++) {
            result[i - 1] = inventory[i];
        }
        return result;
    }

    function getItemsByManufacturer(address account) external view returns (Item[] memory) {
        uint256 count;
        for (uint256 i = 1; i <= totalItems; i++) {
            if (inventory[i].manufacturer == account) count++;
        }
        Item[] memory result = new Item[](count);
        uint256 j;
        for (uint256 i = 1; i <= totalItems; i++) {
            if (inventory[i].manufacturer == account) {
                result[j] = inventory[i];
                j++;
            }
        }
        return result;
    }

    function getActiveListings() external view returns (Listing[] memory) {
        uint256 count;
        for (uint256 i = 1; i <= totalListings; i++) {
            if (listings[i].active) count++;
        }
        Listing[] memory result = new Listing[](count);
        uint256 j;
        for (uint256 i = 1; i <= totalListings; i++) {
            if (listings[i].active) {
                result[j] = listings[i];
                j++;
            }
        }
        return result;
    }

    function getListingsByRetailer(address account) external view returns (Listing[] memory) {
        uint256 count;
        for (uint256 i = 1; i <= totalListings; i++) {
            if (listings[i].retailer == account) count++;
        }
        Listing[] memory result = new Listing[](count);
        uint256 j;
        for (uint256 i = 1; i <= totalListings; i++) {
            if (listings[i].retailer == account) {
                result[j] = listings[i];
                j++;
            }
        }
        return result;
    }

    function getDistributionsByDistributor(address account) external view returns (Distribution[] memory) {
        uint256 count;
        for (uint256 i = 1; i <= totalDistributions; i++) {
            if (distributions[i].distributor == account) count++;
        }
        Distribution[] memory result = new Distribution[](count);
        uint256 j;
        for (uint256 i = 1; i <= totalDistributions; i++) {
            if (distributions[i].distributor == account) {
                result[j] = distributions[i];
                j++;
            }
        }
        return result;
    }
}
