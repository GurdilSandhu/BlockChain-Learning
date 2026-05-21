// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AllGlobalVariables {
    // State variables to store results for demonstration
    uint256 public lastTimestamp;
    address public lastSender;

    function getBlockchainData() public payable returns (
        uint _blockNumber,
        uint _timestamp,
        uint _baseFee,
        uint _prevRandao,
        address _coinbase,
        uint _gasLimit,
        uint _chainId
    ) {
        // --- 1. Block Properties ---
        _blockNumber = block.number;       // Current block number
        _timestamp = block.timestamp;     // Current block timestamp (Unix epoch)
        _baseFee = block.basefee;         // Current block's base fee (EIP-1559)
        _prevRandao = block.prevrandao;   // Randomness from beacon chain (Post-Merge)
        _coinbase = block.coinbase;       // Address of the current block miner/validator
        _gasLimit = block.gaslimit;       // Block gas limit
        _chainId = block.chainid;         // Current network chain ID
        
        lastTimestamp = _timestamp;
    }

    function getTransactionData() public payable returns (
        address _sender,
        uint _value,
        bytes4 _sig,
        bytes calldata _data,
        address _origin,
        uint _gasPrice,
        uint _gasLeft
    ) {
        // --- 2. Message (msg) and Transaction (tx) Properties ---
        _sender = msg.sender;             // Immediate caller of this function
        _value = msg.value;               // Amount of wei sent with the call
        _sig = msg.sig;                   // First 4 bytes of calldata (function selector)
        _data = msg.data;                 // Complete calldata
        
        _origin = tx.origin;               // Wallet that originally started the transaction
        _gasPrice = tx.gasprice;           // Gas price of the transaction
        _gasLeft = gasleft();              // Remaining gas left in this execution
        
        lastSender = _sender;
    }

    function utilityExamples(uint x, uint y) public pure returns (
        bytes32 _hash,
        bytes memory _encoded,
        uint _modSum
    ) {
        // --- 3. Cryptographic and Math Functions ---
        // Computes Keccak-256 hash
        _hash = keccak256(abi.encodePacked(x, y)); 
        
        // --- 4. ABI Encoding ---
        // Encodes data for low-level calls
        _encoded = abi.encode(x, y); 
        
        // --- 5. High-precision Math ---
        // (x + y) % 10 without intermediate overflow
        _modSum = addmod(x, y, 10); 
    }

    function contractDetails() public view returns (address _this, uint _balance) {
        // --- 6. Contract Info ---
        _this = address(this);             // The address of this contract
        _balance = address(this).balance;  // The Ether balance of this contract
    }
}
