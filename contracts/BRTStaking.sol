// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



contract BRTStaking {
    
    IERC20 brtToken;
    IERC721 brtNFT;

    address tokenReserve;

    mapping(address => uint) balances;
    mapping(address => uint) stakedAt;
    mapping(address => uint) nextReward;

    constructor(address _brtToken, address _nftAddress, address _reserve) {
        brtToken = IERC20(_brtToken);
        brtNFT = IERC721(_nftAddress);
        tokenReserve = _reserve;
    }

    function stake(uint _amount) external {
        require(brtNFT.balanceOf(msg.sender) >= 1, "Only BoredApeNFT Owners Can Stake");
        require(brtToken.allowance(msg.sender, address(this)) >= _amount, "Insufficient Allowance");
        require(msg.sender != tokenReserve, "Error");
        bool res = brtToken.transferFrom(msg.sender, tokenReserve, _amount);
        require(res == true, "Failed");
        balances[msg.sender] += _amount;
        stakedAt[msg.sender] = block.timestamp;
        nextReward[msg.sender] = block.timestamp + 30 days;
    }

    function getBalance(address _addr) public view returns(uint) {
        return balances[_addr];
    }

    function getStakedTime(address _addr) public view returns(uint) {
        return stakedAt[_addr];
    }

    function getNextRewardTime(address _addr) public view returns(uint) {
        return nextReward[_addr];
    }

    function claim() external {
        require(block.timestamp - stakedAt[msg.sender] >= 3 days, "You need To Have Staked For 3 Days To claim");
        //require(balances[msg.sender] > 0, "Insufficient Balance");
        require(nextReward[msg.sender] >= block.timestamp, "Next Reward Not Reached.");
        uint reward = (10**17) * balances[msg.sender];
        bool res = brtToken.transferFrom(tokenReserve, msg.sender, reward);
        require(res == true, "Failed");
        nextReward[msg.sender] = block.timestamp + 30 days;
    }

    function withdraw() external {
        bool res;
        require(balances[msg.sender] > 0);
        if (nextReward[msg.sender] >= block.timestamp) {
            uint reward = balances[msg.sender]/10;
            res = brtToken.transferFrom(tokenReserve, msg.sender, reward);
            require(res == true, "Error");
        }
        res = brtToken.transferFrom(tokenReserve, msg.sender, balances[msg.sender]);
        balances[msg.sender] = 0;
        require(res == true, "Error");
    }
}