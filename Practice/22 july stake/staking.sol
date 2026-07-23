// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Staking
/// @notice Simple fixed-term staking contract with 30/60/90 day plans.
/// @dev Rewards are only paid out once the chosen lock period has fully
///      elapsed; there is no partial/early-withdrawal reward path in this
///      version (see NOTE in withdrawToken if you want to change that).
contract Staking {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    address public immutable owner;

    /// @notice Fee taken on deposit AND on withdrawal, expressed in basis points (50 = 0.5%).
    uint256 public constant FEE_BPS = 50; // 0.5%
    uint256 public constant BPS_DENOMINATOR = 10_000;

    uint256 public constant MIN_DEPOSIT = 100;

    enum Plans { ThirtyDays, SixtyDays, NinetyDays }

    // Lock duration for each plan.
    uint256 public constant THIRTY_DAYS = 300; //Can be changed to 30 days  
    uint256 public constant SIXTY_DAYS = 400; //Can be changed to 60 days 
    uint256 public constant NINETY_DAYS = 500; //Can be changed to 90 days 

    // Reward rate (%) paid out for completing each plan in full.
    uint256 public constant RATE_30 = 5;  // 5%
    uint256 public constant RATE_60 = 6;  // 6%
    uint256 public constant RATE_90 = 7;  // 7%

    struct User {
        uint256 deposit;   // net amount staked (after deposit fee)
        uint256 startTime; // timestamp of deposit
        Plans plan;
        bool active;
    }

    uint256 public totalUsers;
    mapping(address => User) public users;

    event Deposited(address indexed user, uint256 amount, uint256 fee, Plans plan);
    event Withdrawn(address indexed user, uint256 principal, uint256 reward, uint256 fee);
    event TokensRescued(address indexed tokenRescued, uint256 amount, address to);

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied");
        _;
    }

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }

    /// @notice Deposit tokens into a staking plan.
    /// @param amount Amount of tokens to stake (before fee).
    /// @param selectedPlan 0 = 30 days, 1 = 60 days, 2 = 90 days.
    function depositToken(uint256 amount, uint256 selectedPlan) external {
        require(amount >= MIN_DEPOSIT, "Minimum 100 tokens required for staking");
        require(selectedPlan <= uint256(Plans.NinetyDays), "Invalid plan");
        require(!users[msg.sender].active, "Existing stake must be withdrawn first");

        uint256 fee = (amount * FEE_BPS) / BPS_DENOMINATOR;
        uint256 amountDeposited = amount - fee;

        users[msg.sender] = User({
            deposit: amountDeposited,
            startTime: block.timestamp,
            plan: Plans(selectedPlan),
            active: true
        });

        totalUsers++;

        emit Deposited(msg.sender, amountDeposited, fee, Plans(selectedPlan));

        token.safeTransferFrom(msg.sender, owner, fee);
        token.safeTransferFrom(msg.sender, address(this), amountDeposited);
    }

    /// @notice Preview the reward currently owed to the caller.
    /// @dev Returns 0 if the lock period has not completed yet.
    function checkAccountReward() public view returns (uint256 reward) {
        return _pendingReward(msg.sender);
    }

    function _pendingReward(address account) internal view returns (uint256) {
        User memory p = users[account];
        if (!p.active) return 0;

        (uint256 lockDuration, uint256 rate) = _planParams(p.plan);

        if (block.timestamp < p.startTime + lockDuration) {
            return 0; // plan not completed yet
        }

        // Full-term reward: deposit * rate% (paid only once the plan matures).
        return (p.deposit * rate) / 100;
    }

    function _planParams(Plans plan) internal pure returns (uint256 lockDuration, uint256 rate) {
        if (plan == Plans.ThirtyDays) {
            return (THIRTY_DAYS, RATE_30);
        } else if (plan == Plans.SixtyDays) {
            return (SIXTY_DAYS, RATE_60);
        } else {
            return (NINETY_DAYS, RATE_90);
        }
    }

    /// @notice Withdraw principal + reward once the lock period has completed.
    /// NOTE: this design requires the plan to have fully matured before
    /// withdrawal. If you want to support early withdrawal (e.g. principal
    /// only, no reward, maybe a penalty), add a separate `emergencyWithdraw`
    /// function rather than relaxing this check, so the reward math stays safe.
    function withdrawToken() external {
        User memory p = users[msg.sender];
        require(p.active, "No active stake");

        (uint256 lockDuration, ) = _planParams(p.plan);
        require(block.timestamp >= p.startTime + lockDuration, "Stake is still locked");

        uint256 reward = _pendingReward(msg.sender);
        uint256 total = p.deposit + reward;

        uint256 fee = (total * FEE_BPS) / BPS_DENOMINATOR;
        uint256 payout = total - fee;

        // Effects: clear state BEFORE external calls.
        delete users[msg.sender];
        totalUsers--;

        emit Withdrawn(msg.sender, p.deposit, reward, fee);

        // Interactions
        token.safeTransfer(owner, fee);
        token.safeTransfer(msg.sender, payout);
    }

    /// @notice Recover ERC20 tokens accidentally sent to this contract.
    /// @dev Cannot be used to pull out the staking token itself, so staked
    /// user funds can never be rug-pulled through this function.
    function rescueTokens(address tokenAddress, uint256 amount, address to) external onlyOwner {
        require(tokenAddress != address(token), "Cannot rescue staking token");
        require(to != address(0), "Invalid recipient");
        IERC20(tokenAddress).safeTransfer(to, amount);
        emit TokensRescued(tokenAddress, amount, to);
    }

    /// @notice View full details of the caller's stake.
    function getDetails()
        external
        view
        returns (
            uint256 deposit,
            uint256 pendingReward,
            uint256 startTime,
            uint256 unlockTime,
            uint256 timePassed,
            Plans selectedPlan,
            bool active
        )
    {
        User memory p = users[msg.sender];
        (uint256 lockDuration, ) = _planParams(p.plan);
        return (
            p.deposit,
            _pendingReward(msg.sender),
            p.startTime,
            p.active ? p.startTime + lockDuration : 0,
            block.timestamp-p.startTime,
            p.plan,
            p.active
        );
    }
}
