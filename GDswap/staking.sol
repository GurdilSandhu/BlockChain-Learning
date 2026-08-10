// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title Staking
/// @notice Simple fixed-term staking contract with 30/60/90 day plans.
/// But for testing purpose contract has seconds 300, 400,500 for now.
/// @dev Rewards are only paid out once the chosen lock period has fully
///      elapsed; there is no partial/early-withdrawal reward path in this
///      version (see NOTE in withdrawToken if you want to change that).
contract Staking {
    using SafeERC20 for IERC20;

    mapping(address => bool) public supportedTokens;
    address immutable owner;

    /// @notice Fee taken on deposit AND on withdrawal, expressed in basis points (50 = 0.5%).
    uint256 public constant FEE_BPS = 50; // 0.5%
    uint256 public constant BPS_DENOMINATOR = 10000; //for 0.01% presicion we can also use 1000 if 0.1% presicion is fine

    uint256 public constant MIN_DEPOSIT = 100;

    enum Plans {
        ThirtyDays,
        SixtyDays,
        NinetyDays
    }

    // Lock duration for each plan.
    uint256 public constant THIRTY_DAYS = 30 days;
    uint256 public constant SIXTY_DAYS = 40 days;
    uint256 public constant NINETY_DAYS = 50 days;

    // Reward rate (%) paid out for completing each plan in full.
    uint256 public constant RATE_30 = 5; // 5%
    uint256 public constant RATE_60 = 6; // 6%
    uint256 public constant RATE_90 = 7; // 7%

    struct User {
        uint256 deposit; // net amount staked (after deposit fee)
        uint256 startTime; // timestamp of deposit
        Plans plan;
        bool active;
    }

    uint256 public totalUsers;
    mapping(address => mapping(address => User)) public users;

    event Deposited(
        address indexed user,
        uint256 amount,
        uint256 fee,
        Plans plan
    );
    event Compounded(address indexed user, uint256 reward, uint256 newDeposit);
    event Withdrawn(
        address indexed user,
        uint256 principal,
        uint256 reward,
        uint256 fee
    );
    event TokensRescued(
        address indexed tokenRescued,
        uint256 amount,
        address to
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied");
        _;
    }

    constructor(address[] memory _tokens) {
        owner = msg.sender;

        for (uint256 i = 0; i < _tokens.length; i++) {
            require(_tokens[i] != address(0), "Invalid token");
            supportedTokens[_tokens[i]] = true;
        }
    }

    ///Deposit tokens into a staking plan.
    ///amount Amount of tokens to stake (before fee).
    ///selectedPlan 0 = 30 days, 1 = 60 days, 2 = 90 days.
    function depositToken(
        address tokenAddress,
        uint256 amount,
        uint256 selectedPlan
    ) external {
        require(supportedTokens[tokenAddress], "Unsupported token");
        require(
            amount >= MIN_DEPOSIT,
            "Minimum 100 tokens required for staking"
        );
        require(selectedPlan <= uint256(Plans.NinetyDays), "Invalid plan");
        require(
            !users[msg.sender][tokenAddress].active,
            "Existing stake must be withdrawn first"
        );
        IERC20 token = IERC20(tokenAddress);
        uint256 fee = (amount * FEE_BPS) / BPS_DENOMINATOR;
        uint256 amountDeposited = amount - fee;

        users[msg.sender][tokenAddress] = User({
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

    ///If user wants to stake the deposit + reward again after the maturity of Stake
    ///then this function will be used to compound the staking again
    function compoundReward(address tokenAddress) external {
        User storage user = users[msg.sender][tokenAddress];

        require(user.active, "No active stake");

        (uint256 lockDuration, ) = _planParams(user.plan);

        require(
            block.timestamp >= user.startTime + lockDuration,
            "Stake is still locked"
        );

        uint256 reward = _pendingReward(msg.sender,tokenAddress);

        require(reward > 0, "No reward");

        user.deposit += reward;
        user.startTime = block.timestamp;

        emit Compounded(msg.sender, reward, user.deposit);
    }

    ///Preview the reward currently owed to the caller.
    function checkAccountReward(address tokenAddress) public view returns (uint256 reward) {
        return _pendingReward(msg.sender, tokenAddress);
    }

    function _pendingReward(
        address account,
        address tokenAddress
    ) internal view returns (uint256) {
        User memory p = users[account][tokenAddress];
        if (!p.active) return 0;

        (uint256 lockDuration, uint256 rate) = _planParams(p.plan);

        if (block.timestamp < p.startTime + lockDuration) {
            uint256 elapsed = block.timestamp - p.startTime;

            return (p.deposit * rate * elapsed) / (lockDuration * 100);
        }

        return (p.deposit * rate) / 100;
    }

    function _planParams(
        Plans plan
    ) internal pure returns (uint256 lockDuration, uint256 rate) {
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
    /// withdrawal.
    function withdrawToken(address tokenAddress) external {
        User memory p = users[msg.sender][tokenAddress];
        require(p.active, "No active stake");
        (uint256 lockDuration, ) = _planParams(p.plan);
        require(
            block.timestamp >= p.startTime + lockDuration,
            "Stake is still locked"
        );
        IERC20 token = IERC20(tokenAddress);
        uint256 reward = _pendingReward(msg.sender,tokenAddress);
        uint256 total = p.deposit + reward;

        uint256 fee = (total * FEE_BPS) / BPS_DENOMINATOR;
        uint256 payout = total - fee;

        // Effects: clear state BEFORE external calls.
        delete users[msg.sender][tokenAddress];
        totalUsers--;

        emit Withdrawn(msg.sender, p.deposit, reward, fee);

        // Interactions
        token.safeTransfer(owner, fee);
        token.safeTransfer(msg.sender, payout);
    }

    /// @notice View full details of the caller's stake.
    function getDetails(
        address tokenAddress
    )
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
        User memory p = users[msg.sender][tokenAddress];
        (uint256 lockDuration, ) = _planParams(p.plan);
        return (
            p.deposit,
            _pendingReward(msg.sender,tokenAddress),
            p.startTime,
            p.active ? p.startTime + lockDuration : 0,
            block.timestamp - p.startTime,
            p.plan,
            p.active
        );
    }
}
