// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LendingProtocol {
    struct Position {
        uint256 collateralETH;
        uint256 borrowedUSDC;
        bool active;
    }
    
    mapping(address => Position) public positions;
    
    mapping(address => uint256) public lenderBalances;
    uint256 public totalLiquidity;
    uint256 public constant LTV = 75;
    
    uint256 public constant ETH_PRICE = 2000;
    event LiquidityDeposited(address indexed lender, uint256 amount);
    event CollateralDeposited(address indexed borrower, uint256 amount);
    event LoanBorrowed(address indexed borrower, uint256 amount);

    function depositETH() external payable {
        require(msg.value > 0, "Send ETH");
        lenderBalances[msg.sender] += msg.value;
        totalLiquidity += msg.value;
        emit LiquidityDeposited(msg.sender, msg.value);
    }

    function depositCollateral() external payable {
        require(msg.value > 0, "Send collateral");
        positions[msg.sender].collateralETH += msg.value;
        positions[msg.sender].active = true;
        emit CollateralDeposited(msg.sender, msg.value);
    }
    function borrowUSDC() external {
        Position storage user = positions[msg.sender];
        require(user.active, "Deposit collateral first");
        require(user.borrowedUSDC == 0, "Already borrowed");
        uint256 collateralValue = (user.collateralETH / 1 ether) * ETH_PRICE;
       uint256 borrowLimit = (collateralValue * LTV) / 100;
        user.borrowedUSDC = borrowLimit;
        emit LoanBorrowed(msg.sender, borrowLimit);
    }
    function getPoolBalance() external view returns (uint256) {
        return totalLiquidity;
    }
    function getMyCollateral() external view returns (uint256) {
        return positions[msg.sender].collateralETH;
    }
    function getLoanDetails() external view returns (uint256 collateral, uint256 borrowed, bool active){
        Position memory user = positions[msg.sender];
        return (user.collateralETH, user.borrowedUSDC, user.active);
    }
}