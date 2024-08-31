//Script for deploying the etherStake.sol

import { ethers } from "hardhat";
async function main() {
    const [deployer] = await ethers.getSigners();

    console.log(
        "Deploying contracts with the account:",
        deployer.address
    );

    const etherStakeFac = await ethers.getContractFactory("etherStake");
    const etherStakeDeploy = await etherStakeFac.deploy();

    //console.log("Deployed to:", etherStakeDeploy.getAddress());
}
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });

// ContractAddress: 0x83c3296562Ca8bF917f48E772C84eec32A4E27d1 [Verified] 
