// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LendingBorrow {

    address public owner;

    uint256 public constant LTV = 75;
    uint256 public constant LIQUIDATION_THRESHOLD = 80;
    uint256 public constant PRECISION = 1e18;
    uint256 public constant PERCENTAGE_BASE = 100;

    bool private locked;

    modifier onlyOwner() {
        require(msg.sender == owner,"Not owner");
        _;
    }

    modifier nonReentrant() {
        require(!locked,"Reentrant Call");
        locked = true;
        _;
        locked = false;
    }

    constructor() {
        owner = msg.sender;
    }

    struct User {
        address wallet;
        uint256 totalDeposit;
        uint256 borrowingAmount;
        uint256 depositCollateral;
        bool needToPay;
    }

    mapping(address => User) public users;
    mapping(address => bool) public isUser;

    uint256 public totalUsers;

    event Deposit(address indexed user,uint amount);
    event Borrow(address indexed user,uint amount);
    event Repay(address indexed user,uint amount);
    event Withdraw(address indexed user,uint amount);
    event Liquidated(address indexed user,address indexed liquidator,uint debtPaid);

    receive() external payable {}

    function deposit_Collateral() external payable {

        require(msg.value >= 1 ether,"Minimum 1 ETH");

        if(!isUser[msg.sender]){

            users[msg.sender] = User({
                wallet: msg.sender,
                totalDeposit: msg.value,
                borrowingAmount:0,
                depositCollateral:msg.value,
                needToPay:false
            });

            isUser[msg.sender]=true;
            totalUsers++;

        }else{

            users[msg.sender].depositCollateral += msg.value;
            users[msg.sender].totalDeposit += msg.value;

        }

        emit Deposit(msg.sender,msg.value);
    }

    error BorrowLimit(string message,uint256 limit);

    function borrow(uint256 amount) external nonReentrant {

        require(isUser[msg.sender],"User not found");

        uint256 limit = users[msg.sender].depositCollateral * LTV / 100;

        if(amount > limit){
            revert BorrowLimit("Borrow Limit",limit);
        }

        require(address(this).balance >= amount,"Protocol has insufficient funds");

        users[msg.sender].borrowingAmount += amount;
        users[msg.sender].needToPay = true;

        payable(msg.sender).transfer(amount);

        emit Borrow(msg.sender,amount);
    }

    function repayLoan() external payable nonReentrant {

        require(isUser[msg.sender],"User not found");
        require(users[msg.sender].borrowingAmount>0,"No active loan");

        require(msg.value>0,"Zero repayment");

        if(msg.value >= users[msg.sender].borrowingAmount){

            uint excess = msg.value-users[msg.sender].borrowingAmount;

            users[msg.sender].borrowingAmount = 0;
            users[msg.sender].needToPay = false;

            if(excess>0){
                payable(msg.sender).transfer(excess);
            }

        }else{

            users[msg.sender].borrowingAmount -= msg.value;

        }

        emit Repay(msg.sender,msg.value);
    }

    function withdrawCollateral(uint amount) external nonReentrant {

        require(isUser[msg.sender],"User not found");

        require(users[msg.sender].depositCollateral>=amount,"Insufficient collateral");

        uint remainingCollateral = users[msg.sender].depositCollateral-amount;

        if(users[msg.sender].borrowingAmount>0){

            uint borrowLimit = remainingCollateral * LTV /100;

            require(
                users[msg.sender].borrowingAmount<=borrowLimit,
                "Loan exceeds LTV"
            );
        }

        users[msg.sender].depositCollateral-=amount;
        users[msg.sender].totalDeposit-=amount;

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender,amount);
    }

    function getHealthFactor(address user) public view returns(uint256){

        if(users[user].borrowingAmount==0){
            return type(uint256).max;
        }

        uint collateralThreshold =
            users[user].depositCollateral *
            LIQUIDATION_THRESHOLD /
            PERCENTAGE_BASE;

        return
            collateralThreshold *
            PRECISION /
            users[user].borrowingAmount;
    }

    function isLiquidatable(address user) public view returns(bool){

        return getHealthFactor(user)<PRECISION;

    }

    function liquidate(address borrower)
        external
        payable
        nonReentrant
    {
        require(isLiquidatable(borrower),"Healthy position");

        require(msg.value>=users[borrower].borrowingAmount,"Pay full debt");

        uint collateral = users[borrower].depositCollateral;

        users[borrower].depositCollateral=0;
        users[borrower].borrowingAmount=0;
        users[borrower].needToPay=false;

        payable(msg.sender).transfer(collateral);

        emit Liquidated(
            borrower,
            msg.sender,
            msg.value
        );
    }

    function fundProtocol() external payable onlyOwner {}

    function withdrawProtocolFunds(uint amount)
        external
        onlyOwner
    {
        require(address(this).balance>=amount,"Insufficient");

        payable(owner).transfer(amount);
    }

    function contractBalance() external view returns(uint){
        return address(this).balance;
    }
}