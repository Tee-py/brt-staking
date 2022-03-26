// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";



contract BRTStaking {

    IERC20 brtToken;
    IERC721 brtNFT;

    address tokenReserve;
    uint constant minimumStake = 4000;
    uint public totalStaked;

    mapping(address => uint) balances;
    mapping(address => uint) stakedAt;
    mapping(address => uint) lastClaimed;

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


    function stake(uint _amount) external hasNFT hasSufficientAllowance(_amount) notReserve {
        //Checks If User Has Current Stake
        if (balances[msg.sender] > 0){
            //check if stake is already more that 3 days and calculate reward
            if (block.timestamp - stakedAt[msg.sender] >= 3 days){
                //calculate and add to staker balance
                uint curr_reward = (block.timestamp - lastClaimed[msg.sender])*balances[msg.sender]*10/2592000;
                balances[msg.sender] += curr_reward;
                totalStaked += curr_reward;
                lastClaimed[msg.sender] = block.timestamp;
                emit Claim(msg.sender, curr_reward);
            }
        }
        bool res = brtToken.transferFrom(msg.sender, tokenReserve, _amount);
        require(res == true, "Failed");
        balances[msg.sender] += _amount;
        totalStaked += _amount;
        if (stakedAt[msg.sender] == 0){
            stakedAt[msg.sender] = block.timestamp;
        }
        emit Stake(msg.sender, _amount);
    }

    function getBalance(address _addr) public view returns(uint) {
        return balances[_addr];
    }

    function withdraw() external hasStake {
        bool res;
        uint balance = balances[msg.sender];
        uint curr_reward = 0;
        if (block.timestamp - stakedAt[msg.sender] >= 3 days){
            curr_reward = (block.timestamp - lastClaimed[msg.sender])*balances[msg.sender]*10/2592000;
        }
        balance += curr_reward;
        res = brtToken.transferFrom(tokenReserve, msg.sender, balance);
        balances[msg.sender] = 0;
        require(res == true, "Error");
        emit Withdraw(msg.sender, balance);
    }
}