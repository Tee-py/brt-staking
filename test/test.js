const { expect } = require("chai");
const { ethers } = require("hardhat");
const NFT = "0xbc4ca0eda7647a8ab7c2061c2e118a18a936f13d"; 

describe("Test", function () {
  it("Should Deploy And Test", async function () {
    const [owner, addr1] = await ethers.getSigners();
    const BRT = await ethers.getContractFactory("BoredApeToken");
    const Staking = await ethers.getContractFactory("BRTStaking");
    
    const brt = BRT.deploy(10000000);
    await brt.deployed();
    const staking = Staking.deploy(brt.address, NFT, owner.address);
    await staking.deployed();
    
    //Approve Staking Contract To Spend From Reserve
    const approveTx = await brt.approve(staking, brt.balanaceOf(owner));
    const appRect = await approveTx.wait();

    //Send Some Tokens to addr1 for Staking
    const transTx = await brt.transfer(addr1.address, 10000);
    const transRecp = await transTx.wait();

    //Approve Staking Contract To Spend BRT Token from addr1
    const appTrans = await brt.connect(addr1).approve(staking.address, 10000);
    const appRecp = await appTrans.wait();

    //Stake BRT Token
    const stakeTx = await staking.connect(addr1).stake(10000)
    const stakeRecpt = await stakeTx.wait()

    //Get Staking Balance
    const stakeBalance = await staking.connect(addr1).getBalance(addr1.address);
    const balRecpt = await stakeBalance.wait();


    console.log(`BRT Token deployed to: ${brt.address}`);
    console.log(`Staking Contract Deployed to: ${staking.address}`);
    console.log(appRect);
    console.log(appRecp);
    console.log(transRecp);
    console.log(stakeRecpt);
    console.log(balRecpt);
  });
});
