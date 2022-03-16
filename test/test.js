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
    brt.approve(staking, brt.balanaceOf(owner));

    console.log(`BRT Token deployed to: ${brt.address}`);
    console.log(`Staking Contract Deployed to: ${staking.address}`);
  });
});
