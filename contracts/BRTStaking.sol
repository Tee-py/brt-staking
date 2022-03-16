// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



contract BRTStaking {

    IERC20 brtToken;
    IERC721 brtNFT;

    address tokenReserve;
    uint minimumStake = 4000;
    uint public totalStaked;

    mapping(address => uint) balances;
    mapping(address => uint) stakedAt;
    mapping(address => uint) nextReward;

    event Stake(address indexed _owner, uint _amount);
    event Withdraw(address indexed _owner, uint _amount);
    event Claim(address indexed _owner, uint _amount);

    constructor(address _brtToken, address _nftAddress, address _reserve) {
        brtToken = IERC20(_brtToken);
        brtNFT = IERC721(_nftAddress);
        tokenReserve = _reserve;
    }

    modifier hasNFT(){
        require(brtNFT.balanceOf(msg.sender) >= 1, "Only BoredApeNFT Owners Can Stake");
        _;
    }

    modifier hasSufficientAllowance(uint _amount){
        require(brtToken.allowance(msg.sender, address(this)) >= _amount, "Insufficient Allowance");
        _;
    }

    modifier notReserve(){
        require(msg.sender != tokenReserve, "Reserve Address Not Permitted To Stake.");
        _;
    }

    modifier hasStake(){
        require(balances[msg.sender] > 0, "No Stake To Withdraw");
        _;
    }

    modifier canClaim(){
        require(block.timestamp - stakedAt[msg.sender] >= 3 days, "You need To Have Staked For 3 Days To claim");
        require(balances[msg.sender] > 0, "Insufficient Balance");
        require(nextReward[msg.sender] >= block.timestamp, "Next Reward Not Reached.");
        _;
    }

    function stake(uint _amount) external hasNFT hasSufficientAllowance(_amount) notReserve {
        bool res = brtToken.transferFrom(msg.sender, tokenReserve, _amount);
        require(res == true, "Failed");
        balances[msg.sender] += _amount;
        totalStaked += _amount;
        stakedAt[msg.sender] = block.timestamp;
        nextReward[msg.sender] = block.timestamp + 30 days;
        emit Stake(msg.sender, _amount);
    }

    function getBalance(address _addr) public view returns(uint) {
        return balances[_addr];
    }

    function claim() external canClaim {
        uint reward = balances[msg.sender]/10;
        bool res = brtToken.transferFrom(tokenReserve, msg.sender, reward);
        require(res == true, "Failed");
        nextReward[msg.sender] = block.timestamp + 30 days;
        emit Claim(msg.sender, reward);
    }

    function withdraw() external hasStake {
        bool res;
        uint balance = balances[msg.sender];
        if (nextReward[msg.sender] >= block.timestamp) {
            uint reward = balances[msg.sender]/10;
            res = brtToken.transferFrom(tokenReserve, msg.sender, reward);
            require(res == true, "Error");
            emit Claim(msg.sender, reward);
        }
        res = brtToken.transferFrom(tokenReserve, msg.sender, balance);
        balances[msg.sender] = 0;
        require(res == true, "Error");
        emit Withdraw(msg.sender, balance);
    }
}