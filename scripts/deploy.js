import { ethers } from "hardhat";



async function main() {
  const [owner, addr1] = await ethers.getSigners();
  console.log(owner.address, addr1.address);
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
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});